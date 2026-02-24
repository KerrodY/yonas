# frozen_string_literal: true
require './lib/authenticate_user.rb'
require './app/models/company_application.rb'

module Forms
  extend Discordrb::EventContainer
  include AuthenticateUser

  application_command(:apply) do |event|
    next unless AuthenticateUser.authorized?(event, :guest)

    event.show_modal(title: 'Company Application', custom_id: 'join_application') do |modal|
      modal.row do |row|
        row.text_input(
          style: :short,
          custom_id: 'years_of_experience',
          label: 'How many hours have you played?',
          placeholder: '100, 200, 2000 etc',
          required: true
        )
      end

      modal.row do |row|
        row.text_input(
          style: :short,
          custom_id: 'pvp_player',
          label: 'Are you a PvP player?',
          placeholder: 'Yes/No',
          required: true
        )
      end

      modal.row do |row|
        row.text_input(
          style: :short,
          custom_id: 'ign',
          label: 'What is your in-game name?',
          required: true,
          placeholder: 'Name'
        )
      end

      modal.row do |row|
        row.text_input(
          style: :short,
          custom_id: 'role',
          label: 'What role do you play in PvP?',
          placeholder: 'DPS, Ranged DPS, Healer, Tank, Mage',
          required: true
        )
      end

      modal.row do |row|
        row.text_input(
          style: :paragraph,
          custom_id: 'extra_info',
          label: 'War/Leadership/Raid experience etc.',
          placeholder: '...',
          required: false
        )
      end
    end
  end

  modal_submit custom_id: 'join_application' do |event|
    application = CompanyApplication.new(
      server_id: event.server.id,
      discord_name: event.user.name,
      status: 'pending',
      years_of_experience: event.value('years_of_experience'),
      pvp_player: event.value('pvp_player'),
      ign: event.value('ign'),
      role: event.value('role'),
      extra_info: event.value('extra_info')
    )

    if application.save
      event.respond(content: "Thanks for submitting your application. You selected PvP: #{event.value('pvp_player')}", ephemeral: true)

      # Find or create the 'applications' channel
      applications_channel = event.server.channels.find { |channel| channel.name == DATA::CHANNELS[:APPLICATIONS][:name] }
      total_applications = CompanyApplication.where(server_id: event.server.id, status: 'pending').count

      applications_channel.send_message("New company application submitted by #{event.user.name}. Total applications: #{total_applications}. Use `/review_applications` to review.")
    else
      event.respond(content: "There was an error submitting your application. Please contact an admin.", ephemeral: true)
    end
  end

  application_command(:review_applications) do |event|
    next unless AuthenticateUser.authorized?(event, :staff)

    applications = CompanyApplication.where(server_id: event.server.id, status: 'pending')

    event.respond(content: "Loading all (#{applications.count}) pending applications...\n", ephemeral: true)
    applications_channel = event.server.channels.find { |channel| channel.name == DATA::CHANNELS[:APPLICATIONS][:name] }

    applications.each do |application|
      embed = Discordrb::Webhooks::Embed.new(
        title: "Application from #{application.discord_name}",
        description: "Details: ",
        color: 0x00ff00
      )

      embed.add_field(name: 'Hours played', value: application.years_of_experience.to_s, inline: true)
      embed.add_field(name: 'PvP Player', value: application.pvp_player.to_s, inline: true)
      embed.add_field(name: 'IGN', value: application.ign, inline: true)
      embed.add_field(name: 'Role', value: application.role, inline: true)
      embed.add_field(name: 'Extra Info', value: application.extra_info.to_s, inline: true)
      embed.add_field(name: 'Status', value: application.status, inline: true)
      embed.add_field(name: 'Discord', value: application.discord_name, inline: true)

      components = Discordrb::Components::View.new
      components.row do |r|
        r.button(style: :success, label: ' Approve', custom_id: "approve_#{application.id}", emoji: '👍')
        r.button(style: :danger, label: ' Reject', custom_id: "reject_#{application.id}",  emoji: '👎')
      end

      applications_channel.send_message('', false, embed, nil, nil, nil, components)
    end
  end

  button do |event|
    action, id = event.custom_id.split('_', 2)
    next unless %w[approve reject].include?(action)

    application = CompanyApplication.find(id.to_i)
    new_status = action == 'approve' ? 'approved' : 'rejected'
    application.update(status: new_status)

    if action == 'approve'
      user = event.server.members.find { |member| member.username == application.discord_name }

      if user
        member_role = event.server.roles.find { |role| role.name == 'Member' }
        guest_role = event.server.roles.find { |role| role.name == 'Guest' }
        user.add_role(member_role) if member_role
        user.remove_role(guest_role) if guest_role
        user.nick = application.ign
      end
    end

    event.respond(content: "Application from #{application.discord_name} has been #{new_status}.")
    event.message.delete
  end

  def self.register_commands(bot, server_id:)
    bot.register_application_command(:apply, 'join_application', server_id:) do |cmd|
    end

    bot.register_application_command(:review_applications, 'Review all pending applications', server_id:) do |cmd|
    end
  end
end
