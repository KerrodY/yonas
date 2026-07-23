# frozen_string_literal: true

# Contract for a game profile. Subclasses provide the game-specific data;
# everything here raises so a half-implemented profile fails loudly.
module Game
  class Base
    # Generic access levels, ranked most to least privileged. Commands check
    # against these; each game maps them to its own role names via #access_roles.
    # A ranked check for a level admits that level and every level above it.
    ACCESS_LEVELS = %i[admin staff helper member guest].freeze

    # Reusable, cumulative Discord permission building blocks for #server_roles.
    def guest_permissions
      %i[read_messages send_messages connect speak use_voice_activity use_slash_commands
         request_to_speak use_public_threads use_private_threads send_messages_in_threads]
    end

    def member_permissions
      guest_permissions + %i[create_instant_invite add_reactions stream embed_links
                             attach_files read_message_history use_external_emoji use_embedded_activities]
    end

    def officer_permissions
      member_permissions + %i[move_members manage_nicknames manage_messages mute_members deafen_members]
    end

    def management_permissions
      officer_permissions + %i[priority_speaker kick_members ban_members manage_channels manage_roles]
    end

    def administrator_permissions
      %i[administrator]
    end

    # Human-readable game name, e.g. "New World"
    def display_name
      raise NotImplementedError, "#{self.class} must implement #display_name"
    end

    # The ranked server roles to create during setup, most privileged first:
    # array of { name:, colour:, permissions: }
    def hierarchy_roles
      raise NotImplementedError, "#{self.class} must implement #hierarchy_roles"
    end

    # Maps each generic access level to the game role names that satisfy it:
    # { admin: %w[Governor Consul], staff: %w[Officer], ... }
    # Levels may be omitted; a level may map to several roles.
    def access_roles
      raise NotImplementedError, "#{self.class} must implement #access_roles"
    end

    # Role names that satisfy an access check for `level`.
    # Ranked (default): the level and every level above it. Exact: only that level.
    # `:any` matches any hierarchy role.
    def role_names_for(level, exact: false)
      return access_roles.values.flatten.uniq if level == :any

      levels = exact ? [level] : ACCESS_LEVELS[0..ACCESS_LEVELS.index(level)]
      levels.flat_map { |lvl| access_roles.fetch(lvl, []) }.uniq
    end

    # Game-specific server roles to create during setup (e.g. crafting roles).
    # Array of hashes: { name:, emoji:, colour: }
    def game_roles
      raise NotImplementedError, "#{self.class} must implement #game_roles"
    end

    # Weapon/class roles: array of { name:, emoji: }
    def weapons
      raise NotImplementedError, "#{self.class} must implement #weapons"
    end

    # Weapon choices for slash command options: { "Display" => "value" }
    def weapon_params
      raise NotImplementedError, "#{self.class} must implement #weapon_params"
    end

    # Reaction-role embeds: array of { title:, roles: [{ name:, emoji: }] }
    def react_role_groups
      raise NotImplementedError, "#{self.class} must implement #react_role_groups"
    end

    # Build registration fields as slash command choices: { "Display" => "value" }
    def heartrunes
      raise NotImplementedError, "#{self.class} must implement #heartrunes"
    end

    def armour_weights
      raise NotImplementedError, "#{self.class} must implement #armour_weights"
    end

    def builds
      raise NotImplementedError, "#{self.class} must implement #builds"
    end

    # Game server/world list for slash command choices: { "Display" => "value" }
    def servers
      raise NotImplementedError, "#{self.class} must implement #servers"
    end

    # Classes with a `#start` method to run as scheduled background tasks
    # (scrapers, cleanups). Return [] for games with no notifications.
    def notifiers
      []
    end
  end
end
