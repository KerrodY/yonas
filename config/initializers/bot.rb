
require 'discordrb'
require 'byebug'
require 'open-uri'
require 'nokogiri'
require './app/commands/commands.rb'

puts 'Bot is loading!'

bot = Discordrb::Commands::CommandBot.new(token: 'MTE1OTcyNTg2NTE0NDQzNDcyOQ.GkHtf7.4ubcd_MT4aaseURGxD9NrwoyQG8DWt3T6oW8f0',      prefix: '/')


# Dir["#{Rails.root}/app/commands/*.rb"].each { |file| require file }
RegisterSlashCommands.register_commands(bot)
bot.include! SlashCommands

bot.run



