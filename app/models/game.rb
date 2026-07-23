# frozen_string_literal: true

# Namespace and registry for game profiles. A game profile packages
# everything about a specific game that Yonas needs: rank names, roles,
# reaction-role groups, build fields, and notification scrapers.
#
# Servers select their game (stored as ServerConfig); the rest of the app
# asks `Game.for(server)` and never hardcodes a game. A nil return means the
# server hasn't selected yet — the bot must not create anything there.
module Game
  REGISTRY = {
    'new_world' => 'Game::NewWorld'
  }.freeze

  def self.registry
    REGISTRY
  end

  # Profile instance for a registered game key, e.g. Game.find('new_world')
  def self.find(key)
    profile_class = REGISTRY[key.to_s]
    raise ArgumentError, "Unknown game: #{key.inspect} (registered: #{REGISTRY.keys.join(', ')})" unless profile_class

    @profiles ||= {}
    @profiles[key.to_s] ||= profile_class.constantize.new
  end

  # The game profile a Discord server selected, or nil if none yet.
  # Accepts a Discordrb server object or a raw server id.
  def self.for(server)
    server_id = server.respond_to?(:id) ? server.id : server
    config = ServerConfig.find_by(server_id: server_id.to_s)
    config && find(config.game)
  end
end
