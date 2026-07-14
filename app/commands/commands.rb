# frozen_string_literal: true

require './app/models/update_notification.rb'
require './lib/authenticate_user.rb'
require './app/services/discord_bot'
require './lib/data.rb'

module Commands
  extend Discordrb::EventContainer
  include AuthenticateUser

  application_command(:help) do |event|
    next unless AuthenticateUser.authorized?(event)

    commands = DiscordBot.instance.bot.get_application_commands
    help_message = "Here are the available commands:\n\n"

    commands.each do |command|
      help_message += "**/#{command.name}**: #{command.description}\n"
    end

    event.respond(content: help_message, ephemeral: true)
  end

  application_command(:server_status) do |event|
    next unless AuthenticateUser.authorized?(event)

    html = URI.open(DATA::WEBSITE_SERVER_STATUS)
    doc = Nokogiri::HTML(html)

    div = doc.at("div.ags-ServerStatus-content-responses-response-server-name:contains('#{event.options['server']}')").parent

    if div
      status = div.at_css('div.ags-ServerStatus-content-responses-response-server-status')['title']

      case status
      when 'Online'
        event.respond(content: "#{event.options['server']} is **Online**")
      when 'Maintenance'
        event.respond(content: "#{event.options['server']} is in **Maintenance**")
      when 'Offline'
        event.respond(content: "#{event.options['server']} is **Offline**")
      else
        event.respond(content: "Status for #{event.options['server']} is **Unavailable**")
      end
    else
      event.respond(content: "Server not found or status is unavailable")
    end
  end

  application_command(:scorpio) do |event|
    next unless AuthenticateUser.authorized?(event)

    @scorpio = true
    channel_id = event.channel.id
    channel = event.bot.channel(channel_id)
    timezone = Time.now.zone == 'AUS Eastern Summer Time' ? 'AEST' : 'AEDT'
    spawn_time = Time.zone.now + (89 * 60)
    event.respond(content: "Scorpio will be spawning roughly at #{spawn_time.strftime("%I:%M %p - #{timezone} - %B %d, %Y")}")
    loop do
      remaining_time = spawn_time - Time.zone.now
      break if remaining_time <= 0 || !@scorpio
      if remaining_time <= 30 * 60 && remaining_time > 29 * 60
        channel.send_message("Scorpio will be spawning in 30 minutes")
      elsif remaining_time <= 10 * 60 && remaining_time > 9 * 60
        channel.send_message("Scorpio will be spawning in 10 minutes")
      elsif remaining_time <= 2 * 60 && remaining_time > 1 * 60
        channel.send_message("Scorpio will be spawning in 2 minutes")
      end
      sleep(61) # Sleep 61 seconds so logic checks work
    end
  end

  application_command(:scorpio_stop) do |event|
    next unless AuthenticateUser.authorized?(event)

    @scorpio = false
  end

  application_command(:list_members) do |event|
    next unless AuthenticateUser.authorized?(event)

    member_role = event.server.roles.find { |role| role.name == 'Member' }
    members_with_role = event.server.members.select { |member| member.role?(member_role) }

    if members_with_role.any?
      sorted_members = members_with_role.sort_by(&:display_name)
      member_list = sorted_members.map(&:display_name).join("\n")
      event.respond(content: "Members with the 'Member' role:\n#{member_list}")
    else
      event.respond(content: "No members with the 'Member' role found.")
    end
  end

  application_command(:subscribe_to_updates) do |event|
    next unless AuthenticateUser.authorized?(event, :staff)

    UpdateNotification.create(channel_id: event.channel.id)
    event.respond(content: "Subscribed to updates")
  end

  application_command(:unsubscribe_to_updates) do |event|
    next unless AuthenticateUser.authorized?(event, :staff)

    UpdateNotification.where(channel_id: event.channel.id).delete_all
    event.respond(content: "Unsubscribed to updates")
  end

  application_command(:roll) do |event|
    next unless AuthenticateUser.authorized?(event)

    roll = rand(1..6)
    event.respond(content: "Rolled #{roll}")
  end

  application_command(:cleanse) do |event|
    next unless AuthenticateUser.authorized?(event, :governor)

    server = event.server
    owner_id = server.owner.id
    kicked_users = []

    server.members.each do |member|
      next if member.id == owner_id || member.bot_account?

      member.kick
      kicked_users << {
        display_name: member.display_name,
        discord_name: member.username,
        discord_id: member.id
      }
    end

    kicked_users.each do |user|
      Rails.logger.info "Kicked user: Display Name: #{user[:display_name]}, Discord Name: #{user[:discord_name]}, Discord ID: #{user[:discord_id]}"
    end

    event.respond(content: "Total users kicked: #{kicked_users.size}")
  end

  def self.register_commands(bot, server_id:)
    bot.register_application_command(:help, 'List all Yonas commands', server_id:) do |cmd|
    end

    bot.register_application_command(:server_status, 'Check the server status', server_id:) do |cmd|
      cmd.string('server', 'Select your server', required: true, choices: DATA::SERVERS)
    end

    bot.register_application_command(:scorpio_stop, 'Clear scorpio timer', server_id:) do |cmd|
    end

    bot.register_application_command(:scorpio, 'Scorpio killed and set timer for respawn the next night', server_id:) do |cmd|
    end

    bot.register_application_command(:subscribe_to_updates, 'Subscribe to news and updates from New World website and social media', server_id:) do |cmd|
    end

    bot.register_application_command(:unsubscribe_to_updates, 'Unsubscribe to news and updates', server_id:) do |cmd|
    end

    bot.register_application_command(:roll, 'Roll the dice', server_id:) do |cmd|
    end

    bot.register_application_command(:list_members, 'List everyone with the member role', server_id:) do |cmd|
    end

    bot.register_application_command(:cleanse, 'Cleanse', server_id:) do |cmd|
    end
  end
end
