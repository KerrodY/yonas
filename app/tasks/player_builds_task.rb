# frozen_string_literal: true

require 'rufus-scheduler'
require './app/services/discord_bot'

class PlayerBuildsTask
  def start
    scheduler = Rufus::Scheduler.new

    scheduler.every '1h' do
      # delete_non_member_builds
    end
  end

  private

  def delete_non_member_builds
    DiscordBot.instance.bot.servers.each_value do |server|
      member_role = server.roles.find { |role| role.name == 'Member' }
      next unless member_role

      member_discord_ids = member_role.members.map(&:username)
      server_players = PlayerBuild.where(server_id: server.id)
      builds_to_delete = server_players.where.not(discord_id: member_discord_ids)

      deleted_display_names = builds_to_delete.map(&:discord_id)

      result = builds_to_delete.destroy_all

      Rails.logger.info "Deleted server (#{server.name} - #{server.id}) non-member builds for: #{deleted_display_names.join(', ')}" unless result.empty?
    end
  end
end
