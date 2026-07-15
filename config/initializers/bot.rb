require 'discordrb'
require 'open-uri'
require 'nokogiri'
require './app/models/application_record'
require './app/tasks/new_world_notifications'
require './app/tasks/player_builds_task'
require './app/services/discord_bot'

# Only start the schedulers and bot when actually serving the app — not in tests,
# the console, rake-style tasks (assets:precompile, db:prepare), or Docker builds.
running_task = File.basename($PROGRAM_NAME) == 'rake' || ARGV.first.to_s.include?(':')

unless Rails.env.test? || defined?(Rails::Console) || running_task || ENV['SECRET_KEY_BASE_DUMMY']
  Rails.logger.info 'Starting up New World Notifications...'
  NewWorldNotifications.new.start

  Rails.logger.info 'Starting up pvp_build tasks...'
  PlayerBuildsTask.new.start

  Rails.logger.info 'Starting up discord bot...'
  DiscordBot.instance
end
