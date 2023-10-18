require './app/models/influence_push.rb'

module RegisterSlashCommands
  def self.register_commands(bot)
    bot.register_application_command(:server_online, 'Ping when the server is back online') do |cmd|
    end

    bot.register_application_command(:server_status, 'Check the server status') do |cmd|
    end

    bot.register_application_command(:scorpio_stop, 'Clear scorpio timer') do |cmd|
    end

    bot.register_application_command(:scorpio, 'Scorpio killed and set timer for respawn the next night') do |cmd|
    end

    bot.register_application_command(:roll, 'Roll the dice') do |cmd|
    end

    bot.register_application_command(:influence_push, 'Register for the influence race') do |cmd|
      cmd.string('name', 'enter your name', required: true,)
      cmd.string('role', 'enter your role', required: true, choices: { dps: 'dps', tank: 'tank', mage: 'mage', healer: 'healer'} )
    end

    bot.register_application_command(:create_pvp_groups, 'Create groups from all register players') do |cmd|
    end

    bot.register_application_command(:delete_pvp_groups, 'Create groups from all register players') do |cmd|
    end
  end
end

module SlashCommands
    extend Discordrb::EventContainer
    extend Discordrb::Events

    application_command(:influence_push) do |event|
      InfluencePush.create!(player: event.options['name'], role: event.options['role'])
      event.respond(content: "Registered!")
    end


    application_command(:delete_pvp_groups) do |event|
      if InfluencePush.count == 0
        event.respond(content: "Destroyed PvP groups")
      else
        event.respond(content: "Error destroying PvP groups")
      end
    end


    application_command(:create_pvp_groups) do |event|
      event.respond(content: "Creating groups")

      groups = InfluencePush.new.create_pvp_groups
      puts groups
      # Initialize a variable to store the message content
      message_content = ""

      # Iterate over groups and players
      groups.each do |group_num, players|
        temp = "Group #{group_num + 1}:"

        # Add group information to the message content
        message_content += "#{temp}\n"

        players.each do |player|
          # Add player information to the message content
          message_content += "#{player[:player]} : #{player[:role]}\n"
        end

        # Add a line break between groups
        message_content += "\n"
      end

      # Send the combined message
      event.send_message(content: message_content)


    end

    application_command(:server_online) do |event|
      event.respond(content: "I will notify when you the server is back online!")

      channel_id = event.channel.id
      url = 'https://www.newworld.com/en-us/support/server-status'


      loop do
        # Fetch the HTML content from the URL
        html = URI.open(url).read

        doc = Nokogiri::HTML(html)

        # Find the div with the value "Delos"
        div_delos = doc.at('div.ags-ServerStatus-content-responses-response-server-name:contains("Delos")')

        puts div_delos

        if div_delos
          # Get the parent div
          parent_div = div_delos.parent

          if parent_div
            # Check the children of the parent div for a div with title "Maintenance"
            #maintenance_div = parent_div.css('div[title="Maintenance"]').first
            online_div = parent_div.css('div[title="Online"]').first

            puts online_div

            if online_div
              channel = channel(channel_id)
              channel&.send_message("Server is online @here")

              break
            end
          else
            puts "No parent div found for the 'Delos' div."
          end
        else
          puts "The div with the value 'Delos' does not exist."
        end
        sleep(60)
      end

    end

    application_command(:scorpio) do |event|
      @scorpio = true
      channel_id = event.channel.id
      channel = channel(channel_id)
      timezone = Time.now.zone == 'AUS Eastern Summer Time' ? 'AEST' : 'AEDT'
      spawn_time = Time.now + (89 * 60)
      event.respond(content: "Scorpio will be spawning roughly at #{spawn_time.strftime("%I:%M %p - #{timezone} - %B %d, %Y")}")
      thirty_minutes, ten_minutes, two_minutes = nil
      loop do
        remaining_time = spawn_time - Time.now
        break if remaining_time <= 0 || !@scorpio
        if remaining_time <= 30 * 60 && remaining_time > 29 * 60
          thirty_minutes = channel.send_message("Scorpio will be spawning in 30 minutes")
        elsif remaining_time <= 10 * 60 && remaining_time > 9 * 60
          ten_minutes = channel.send_message("Scorpio will be spawning in 10 minutes")
        elsif remaining_time <= 2 * 60 && remaining_time > 1 * 60
          two_minutes = channel.send_message("Scorpio will be spawning in 2 minutes")
        end
        sleep(61) # Sleep 61 seconds so logic checks work
      end

    end

    application_command(:scorpio_stop) do |event|
      @scorpio = false
    end

    application_command(:roll) do |event|
      roll = rand(1..6)
      event.respond(content: "Rolled #{roll}")
    end

    application_command(:server_status) do |event|
        event.respond(content: "Checking server status...")
        url = 'https://www.newworld.com/en-us/support/server-status'

        # Fetch the HTML content from the URL
        html = URI.open(url).read

        doc = Nokogiri::HTML(html)
        # Find the div with the value "Delos"
        div_delos = doc.at('div.ags-ServerStatus-content-responses-response-server-name:contains("Delos")')

        if div_delos
          # Get the parent div
          parent_div = div_delos.parent

          if parent_div
            # Check the children of the parent div for a div with title "Maintenance"
            maintenance_div = parent_div.css('div[title="Maintenance"]').first
            online_div = parent_div.css('div[title="Online"]').first

            if maintenance_div
              event.send_message(content: "Server is under maintenance")
            elsif online_div
              event.send_message(content: "Server is online")
            else
              event.send_message(content: "Server status is unavailable")
            end
          else
            puts "Found Delos server but cannot find status"
          end
        else
          puts "Error finding Delos status"
        end
      end
end