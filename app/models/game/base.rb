# frozen_string_literal: true

# Contract for a game profile. Subclasses provide the game-specific data;
# everything here raises so a half-implemented profile fails loudly.
module Game
  class Base
    # Human-readable game name, e.g. "New World"
    def display_name
      raise NotImplementedError, "#{self.class} must implement #display_name"
    end

    # Game-specific server roles to create during setup (e.g. crafting roles).
    # Array of hashes: { name:, emoji:, colour:, permissions: }
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
