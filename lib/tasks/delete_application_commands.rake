# lib/tasks/delete_application_commands.rake

namespace :discord do
  desc 'Delete all registered application commands'
  task delete_application_commands: :environment do
    bot = DiscordBot.instance.bot

    # Fetch all global application commands
    global_commands = bot.get_application_commands

    # Delete each global command
    global_commands.each do |command|
      bot.delete_application_command(command.id)
      puts "Deleted global command: #{command.name} (ID: #{command.id})"
    end

    # Fetch all guild-specific application commands
    bot.servers.each_value do |server|
      guild_commands = bot.get_application_commands(server_id: server.id)
      guild_commands.each do |command|
        bot.delete_application_command(command.id, server_id: server.id)
        puts "Deleted guild command: #{command.name} (ID: #{command.id}) from server: #{server.name} (ID: #{server.id})"
      end
    end

    puts 'All application commands have been deleted. Please restart the bot to re-register the commands.'
  end
end
