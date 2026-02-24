require 'discordrb'
require 'open-uri'
require 'nokogiri'
require './app/models/application_record'
require './app/tasks/new_world_notifications'
require './app/tasks/player_builds_task'
require './app/services/discord_bot'

unless Rails.env.test? || defined?(Rails::Console)
  Rails.logger.info 'Starting up New World Notifications...'
  NewWorldNotifications.new.start

  Rails.logger.info 'Starting up pvp_build tasks...'
  PlayerBuildsTask.new.start

  Rails.logger.info 'Starting up discord bot...'
  DiscordBot.instance
end
