# frozen_string_literal: true

class Setup
  def initialize(bot, server = nil)
    @bot = bot
    @server = server
    create
  end

  private

  def create
    if @server
      create_roles(@server)
      create_server_channels(@server)
      create_react_roles(@server)
    else
      @bot.servers.each_value do |server|
        create_roles(server)
        create_server_channels(server)
        create_react_roles(server)
      end
    end
  end

  def create_server_channels(server)
    yonas_category = server.categories.find { |category| category.name == 'YONAS' }
    yonas_category ||= server.create_channel('YONAS', 4) unless yonas_category

    return unless yonas_category

    DATA::YONAS_CHANNELS.each do |yonas_channel|
      existing_channel = server.channels.find { |channel| channel.name == yonas_channel[:name] && channel.category == yonas_category }

      next if existing_channel

      # Create the channel (all roles are guaranteed to exist at this point)
      server.create_channel(
        yonas_channel[:name],
        yonas_channel[:type],
        parent: yonas_category,
        topic: yonas_channel[:topic],
        permission_overwrites: format_permissions(yonas_channel[:permission_overwrites], server)
      )
      Rails.logger.debug { "Created 'Yonas' channel: #{yonas_channel} for server: #{server.name}" }
    end
  end

  def format_permissions(permissions, server)
    return unless permissions

    permissions.map do |permission|
      role = permission[:role] == 'g' ? server.everyone_role : server.roles.find { |r| r.name == permission[:role] }

      overwrite_params = {}

      overwrite_params[:allow] = Discordrb::Permissions.new(permission[:allow]) if permission[:allow]
      overwrite_params[:deny] = Discordrb::Permissions.new(permission[:deny]) if permission[:deny]

      Discordrb::Overwrite.new(role, **overwrite_params)
    end
  end

  def create_roles(server)
    DATA::SERVER_ROLES.each do |role_data|
      existing_role = server.roles.find { |role| role.name == role_data[:name] }

      next if existing_role

      server.create_role(name: role_data[:name], colour: role_data[:colour], mentionable: true, permissions: role_data[:permissions])
      Rails.logger.info("Created server role: #{role_data} for server: #{server.name}")
    end

    # DATA::WEAPONS.each_value do |weapon_name|
    #   existing_role = server.roles.select { |r| r.name == weapon_name }
    #
    #   next if existing_role.empty?
    #
    #   begin
    #     existing_role.each { it.delete }
    #     puts("Deleted weapon role: #{weapon_name} for server: #{server.name}")
    #   rescue Discordrb::Errors::NoPermission
    #     puts("Failed to delete weapon role: #{weapon_name} for server: #{server.name}")
    #     next
    #   end
    # end

    DATA::WEAPONS_PARAMS.each_key do |weapon_name|
      existing_role = server.roles.find { |r| r.name == weapon_name }
      next if existing_role

      server.create_role(name: weapon_name, colour: 0x808080, hoist: false, mentionable: true)
      Rails.logger.info("Created weapon role: #{weapon_name} for server: #{server.name}")
    end
  end

  def create_react_roles(server)
    reaction_roles_channel = server.channels.find { |channel| channel.name == DATA::CHANNELS[:ROLES][:name] }
    return unless reaction_roles_channel

    # Each react role group is identified by its embed title, so setup stays idempotent per group
    existing_titles = reaction_roles_channel.history(50)
                                            .select { |msg| msg.author.id == @bot.profile.id }
                                            .filter_map { |msg| msg.embeds.first&.title }

    DATA::REACT_ROLES.each do |group|
      next if existing_titles.include?(group[:title])

      embed = Discordrb::Webhooks::Embed.new(
        title: group[:title],
        description: 'React to this message with the corresponding emoji to get the role. Remove your reaction to remove the role.',
        color: 0x00ff00
      )

      group[:roles].each do |reaction_role|
        embed.add_field(name: reaction_role[:name], value: reaction_role[:emoji], inline: true)
      end

      message = reaction_roles_channel.send_message(nil, false, embed)

      group[:roles].each do |reaction_role|
        message.react(reaction_role[:emoji])
      end

      Rails.logger.info("Created '#{group[:title]}' reaction roles message in channel: #{reaction_roles_channel.name} for server: #{server.name}")
    end
  end
end
