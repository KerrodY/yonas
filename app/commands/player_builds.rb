require './app/models/player_build.rb'
require './lib/authenticate_user.rb'
require 'csv'

module PlayerBuilds
  extend Discordrb::EventContainer
  include AuthenticateUser

  private

  def self.format_builds_table(builds)
    header = "#{'Player'.ljust(16)} | #{'Role'.ljust(10)} | #{'Weapon 1'.ljust(16)} | #{'Weapon 2'.ljust(16)} | #{'Armour'.ljust(6)} | #{'Heartrune'.ljust(14)}"
    separator = "#{'-' * 16} | #{'-' * 10} | #{'-' * 16} | #{'-' * 16} | #{'-' * 6} | #{'-' * 14}"

    message = "```\n#{header}\n#{separator}\n"

    builds.each do |build|
      message += "#{build.player.ljust(16)} | #{build.role.ljust(10)} | #{build.weapon_1.ljust(16)} | #{build.weapon_2.ljust(16)} | #{build.armour_weight.ljust(6)} | #{build.heartrune.ljust(14)}\n"
    end

    message += "```"
    message
  end

  application_command(:search_pvp_builds) do |event|
    next unless AuthenticateUser.authorized?(event, :member)

    event.respond(content: "Loading matching players pvp builds...\n", ephemeral: true)
    channel = event.bot.channel(event.channel.id)

    results = PlayerBuild.search_for_builds(event)

    if results
      results.each_slice(10) do |batch|
        message = format_builds_table(batch)
        channel.send_message(message)
      end
    else
      channel.send_message("No matches found", ephemeral: true)
    end
  end

  application_command(:delete_pvp_build) do |event|
    next unless AuthenticateUser.authorized?(event, :any)

    PlayerBuild.remove_pvp_build(event)

    event.respond(content: "Deleted #{event.options['name']}'s build!", ephemeral: true)
  end

  application_command(:unregistered_pvp_builds) do |event|
    next unless AuthenticateUser.authorized?(event, :staff)

    member_role = event.server.roles.find { |role| role.name == 'Member' }
    members_without_builds = []

    if member_role
      event.server.members.each do |member|
        if member.role?(member_role)
          player_build = PlayerBuild.find_by(discord_id: member.username)
          members_without_builds << member.display_name unless player_build
        end
      end
    end

    if members_without_builds.empty?
      event.respond(content: "All members have a registered PvP build.")
    else
      event.respond(content: "The following members do not have a registered PvP build:\n#{members_without_builds.join("\n")}")
    end
  end

  application_command(:register_pvp_build) do |event|
    next unless AuthenticateUser.authorized?(event, :any)

    guest = event.user.roles.any? { |role| role.name.downcase == 'guest' }

    begin
      PlayerBuild.find_or_initialize_by(discord_id: event.user.username, server_id: event.server.id).update!(
        player: event.user.display_name,
        role: event.options['role'],
        weapon_1: event.options['weapon_1'],
        weapon_2: event.options['weapon_2'],
        heartrune: event.options['heartrune'],
        armour_weight: event.options['armour_weight'],
        guest: guest
      )


      DATA::WEAPONS_PARAMS.each_value do |weapon_name|
        role = event.server.roles.find { |r| r.name == weapon_name }
        event.user.remove_role(role) if role && event.user.role?(role)
      end

      event.user.add_role(event.server.roles.find { |r| r.name == event.options['weapon_1'] })
      event.user.add_role(event.server.roles.find { |r| r.name == event.options['weapon_2'] })
    end

    event.respond(content: "Registered #{event.user.display_name}!", ephemeral: true)
  rescue StandardError => e
    event.respond(content: "An error occurred: #{e.message}")
  end

  application_command(:export_pvp_builds) do |event|
    next unless AuthenticateUser.authorized?(event, :staff)

    builds = PlayerBuild.where(server_id: event.server.id).order(:player)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[Player Role Weapon1 Weapon2 ArmourWeight Heartrune Guest Discord]
      builds.each do |build|
        csv << [build.player, build.role, build.weapon_1, build.weapon_2, build.armour_weight, build.heartrune, build.guest, build.discord_id]
      end
    end

    file_path = "tmp/pvp_builds_#{Time.now.to_i}.csv"
    File.write(file_path, csv_data)

    event.channel.send_file(File.open(file_path), caption: "Here are the exported PvP builds.")
    event.respond(content: "Exported :)", ephemeral: true)
  ensure
    File.delete(file_path) if File.exist?(file_path)
  end

  application_command(:show_pvp_builds) do |event|
    next unless AuthenticateUser.authorized?(event, :member)

    event.respond(content: "Loading all players pvp builds...\n", ephemeral: true)
    channel_id = event.channel.id
    channel = event.bot.channel(channel_id)

    query = { server_id: event.server.id }
    query[:guest] = event.options['guest'] || false

    builds = PlayerBuild.where(query).order(:player)

    builds.each_slice(10) do |batch|
      message = format_builds_table(batch)
      channel.send_message(message)
    end

    channel.send_message("```\nTotal builds registered: #{builds.count}```")
  end

  def self.register_commands(bot, server_id:)
    bot.register_application_command(:register_pvp_build, 'Register your PvP war build', server_id:) do |cmd|
      cmd.string('role', 'select your role', required: true, choices: DATA::BUILDS)
      cmd.string('weapon_1', 'your first weapon', required: true, choices: DATA::WEAPONS_PARAMS)
      cmd.string('weapon_2', 'your second weapon', required: true, choices: DATA::WEAPONS_PARAMS)
      cmd.string('heartrune', 'your heartrune', required: true, choices: DATA::HEARTRUNES)
      cmd.string('armour_weight', 'your armour weight', required: true, choices: DATA::ARMOUR_WEIGHTS)
    end

    bot.register_application_command(:delete_pvp_build, 'Delete your PvP war build', server_id:) do |cmd|
    end

    bot.register_application_command(:show_pvp_builds, 'Show all registered players pvp builds', server_id:) do |cmd|
      cmd.boolean('guest', 'include guest builds')
    end

    bot.register_application_command(:export_pvp_builds, 'Export all PvP builds to a CSV file', server_id:) do |cmd|
    end

    bot.register_application_command(:unregistered_pvp_builds, 'Show all registered players pvp builds', server_id:) do |cmd|
    end

    bot.register_application_command(:search_pvp_builds, 'Select weapons and/or armour weight to search for players using them', server_id:) do |cmd|
      cmd.string('player', 'enter your name')
      cmd.string('weapon_1', 'first weapon', choices: DATA::WEAPONS_PARAMS)
      cmd.string('weapon_2', 'second weapon', choices: DATA::WEAPONS_PARAMS)
      cmd.string('heartrune', 'your heartrune', choices: DATA::HEARTRUNES)
      cmd.string('armour_weight', 'your armour weight', choices: DATA::ARMOUR_WEIGHTS)
      cmd.boolean('guest', 'include guest builds')
    end
  end
end
