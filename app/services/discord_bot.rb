# frozen_string_literal: true
require './app/commands/commands'
require './app/commands/player_builds'
require './app/commands/influence_push'
require './app/commands/forms'
require './app/commands/pvp_groups'
require './lib/data'
require 'singleton'
require_relative 'start_bot'
require_relative 'setup'

class DiscordBot
  include Singleton

  attr_reader :bot

  COMMANDS = [Commands, PlayerBuilds, InfluencePush, Forms, PvpGroups].freeze

  def initialize
    @bot = StartBot.new.bot
    create_yonas_invite
    setup
  end

  private

  def setup
    COMMANDS.each { |command| bot.include!(command) }

    Setup.new(bot)

    listeners
  end

  # TODO: Pass params correctly
  def create_yonas_invite
    @bot.invite_create({permissions: [:adminstrator], scopes: [:bot, :applications_commands]})
    "Invite URL: #{@bot.invite_url}"
  end

  private

  def listeners
    server_join_event
    member_join_event
    join_to_create_channel_event
    feedback_messages_event
  end

  def feedback_messages_event
    # React with a random emoji to acknowledge the feedback
    bot.message(in: DATA::CHANNELS[:FEEDBACK][:name]) do |event|
      # Save feedback to database
      Feedback.create!(
        message: event.message.content,
        display_name: event.server.member(event.user.id).display_name,
        discord_id: event.user.id.to_s,
        server_id: event.server.id.to_s,
        channel_id: event.channel.id.to_s
      )

      event.message.react(DATA::FEEDBACK_EMOJIS.sample)
    end
  end

  def server_join_event
    bot.server_create do |event|
      Setup.new(bot)
    end
  end

  def member_join_event
    bot.member_join do |event|
      guest_role = event.server.roles.find { |role| role.name == 'Guest' }
      event.user.add_role(guest_role) if guest_role

      welcome_channel = event.server.channels.find { |channel| channel.name == DATA::CHANNELS[:WELCOME][:name] }

      Setup.new(bot) unless welcome_channel

      welcome_channel.send_message("Welcome to #{event.server.name}, #{event.user.mention}! Please use `/apply` to request joining the company.")
    end
  end

  def join_to_create_channel_event
    # Hash to keep track of created temporary channels and users
    temp_channels = {}

    bot.voice_state_update do |event|
      user = event.user
      new_channel = event.channel   # The new channel they joined
      old_channel = event.old_channel   # The previous channel they were in
      guild = event.server

      # When a user joins or moves to the "Join to Create" channel
      if new_channel && new_channel.name == DATA::CHANNELS[:JOIN_TO_CREATE][:name]
        # Create a new temporary voice channel
        join_to_create_channel = guild.channels.find { |channel| channel.name == DATA::CHANNELS[:JOIN_TO_CREATE][:name] && channel.type == 2 }
        category_id = join_to_create_channel.parent_id if join_to_create_channel

        temp_channel = guild.create_channel("#{event.server.member(event.user.id).display_name}'s channel", 2, parent: category_id) # Type 2 is for voice channels

        # Move the user to the new temporary channel
        event.server.move(user, temp_channel)

        # Store the new channel ID and initial user
        temp_channels[temp_channel.id] = { users: [user.id], channel: temp_channel }
      end

      # When a user leaves a channel
      if old_channel
        # If they leave a temporary channel
        if temp_channels.key?(old_channel.id)
          # Remove the user from the temporary channel's user list
          temp_channels[old_channel.id][:users].delete(user.id)

          # If the channel is empty, delete it
          if old_channel.users.empty?
            temp_channels[old_channel.id][:channel].delete
            temp_channels.delete(old_channel.id)
          end
        end
      end
    end
  end
end
