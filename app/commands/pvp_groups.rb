# frozen_string_literal: true

require './app/models/pvp_events.rb'
require './lib/authenticate_user.rb'

module PvpGroups
  extend Discordrb::EventContainer
  include AuthenticateUser

  application_command(:create_pvp_groups) do |event|
    next unless AuthenticateUser.authorized?(event)

    event.respond(content: "Creating PvP groups...")

    groups = PvpEvents.new.create_pvp_groups(event)
    next unless groups

    message_content = ""

    groups.each do |group_num, players|
      message_content += "Group #{group_num + 1}:\n"

      players.each do |player|
        message_content += "#{player[:player]} : #{player[:role]}\n"
      end

      message_content += "\n"
    end

    event.send_message(content: message_content)
  end

  def self.register_commands(bot, server_id:)
    bot.register_application_command(:create_pvp_groups, 'Create groups with all players in this channel', server_id:) do |cmd|
    end
  end
end
