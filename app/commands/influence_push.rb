# frozen_string_literal: true

require './app/models/influence_push_registration'
require './lib/authenticate_user.rb'

module InfluencePush
  extend Discordrb::EventContainer
  include AuthenticateUser

  TERRITORIES = {
    cutless_keys: 'CutlessKeys', monarchs_bluffs: 'MonarchsBluffs', windsward: 'Windsward', reekwater: 'Reekwater',
    restless_shore: 'RestlessShore', everfall: 'Everfall', brightwood: 'Brightwood', weavers_fen: 'WeaversFen',
    edengrove: 'Edengrove', mourningdale: 'Mourningdale', ebonscale_reach: 'EbonscaleReach',
    brimstone_sands: 'BrimstoneSands'
  }.freeze

  application_command(:register_influence_push) do |event|
    next unless AuthenticateUser.authorized?(event, :staff)

    user_channel = event.user.voice_channel
    unless user_channel
      event.respond(content: "You need to be in a voice channel to register an influence push.", ephemeral: true)
      next
    end

    created_records = []
    skipped_records = []

    user_channel.users.each do |user|
      existing_record = InfluencePushRegistration.where(server_id: event.server.id, discord_id: user.username)
                                                 .where('DATE(time) = ?', Time.zone.today)
                                                 .where(territory: event.options['territory'])
                                                 .exists?

      if existing_record
        skipped_records << user.username
      else
        InfluencePushRegistration.create!(server_id: event.server.id, discord_id: user.username, territory: event.options['territory'], time: Time.zone.today)
        created_records << user.username
      end
    end

    event.respond(content: "Registered: #{created_records} players,\nAlready registered: #{skipped_records}")
  end

  application_command(:influence_push_player_totals) do |event|
    next unless AuthenticateUser.authorized?(event, :staff)

    event.respond(content: "Loading players influence push attendance...\n")
    races = InfluencePushRegistration.select(:time, :territory, :server_id)
                                     .where(server_id: event.server.id)
                                     .distinct
                                     .count

    results = InfluencePushRegistration.joins("LEFT JOIN player_builds ON influence_push_registrations.discord_id = player_builds.discord_id")
                                       .where(server_id: event.server.id)
                                       .group('player_builds.player', 'influence_push_registrations.discord_id')
                                       .count

    channel_id = event.channel.id
    channel = event.bot.channel(channel_id)

    if results
      message = "```Player           | Attended         | Average      \n"

      results.each_slice(10) do |batch|
        batch.each do |(player_name, discord_id), total_count|
          if player_name
            percentage = ((total_count.to_f / races) * 100).round(2)

            message += "\n#{player_name.ljust(16)} | #{total_count.to_s.ljust(16)} | #{percentage}%"
          else
            channel.send_message("#{discord_id} has no registered pvp build, skipping")
          end
        end
        message += "```\n"
        channel.send_message(message)
        message = "```"
      end
    else
      channel.send_message("No matches found")
    end
  end

  def self.register_commands(bot, server_id:)
    bot.register_application_command(:register_influence_push, 'Register your participation in the influence push', server_id:) do |cmd|
      cmd.string('territory', 'select the territory', required: true, choices: TERRITORIES)
    end

    bot.register_application_command(:influence_push_player_totals, 'Show all registered players pvp builds', server_id:) do |cmd|
    end
  end
end
