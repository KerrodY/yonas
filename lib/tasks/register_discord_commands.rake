# lib/tasks/register_discord_commands.rake

namespace :discord do
  desc 'Register Discord bot commands'
  task register_commands: :environment do
    require './app/commands/commands'
    require './app/commands/player_builds'
    require './app/commands/influence_push'
    require './app/commands/forms'
    require './app/commands/pvp_groups'

    @server_id = ENV['SERVER_ID']&.to_i

    @bot = StartBot.new.bot

    def commands
      @server_id ? @bot.get_application_commands(server_id: @server_id) : @bot.get_application_commands
    end
    # Check for optional server_id environment variable


    if @server_id
      puts "Refreshing Discord slash commands for guild #{@server_id}..."
    else
      puts 'Refreshing Discord slash commands globally...'
    end

    puts '🗑️ Deleting existing commands...'

    begin
      # First, delete all existing commands
      old_commands = commands
      old_commands.each do |command|
        sleep(1)
        if @server_id
          @bot.delete_application_command(command.id, server_id: @server_id)
        else
          @bot.delete_application_command(command.id)
        end
      end
      puts "✅ Deleted #{old_commands.length} commands"

      DiscordBot::COMMANDS.each do |command|
        sleep(1) # To avoid hitting rate limits
        command.register_commands(@bot, server_id: @server_id)
      end

      puts "📝 Registering #{commands.count} new commands"

      puts '✅ Command refresh complete!'
    rescue StandardError => e
      puts "❌ Error refreshing commands: #{e.message}"
      exit 1
    end
  end
end
