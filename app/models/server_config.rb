# frozen_string_literal: true

# Per-Discord-server bot configuration. A server has no game until an admin
# selects one; until then the bot creates nothing there (see Game.for).
class ServerConfig < ApplicationRecord
  validates :server_id, presence: true, uniqueness: true
  validates :game, presence: true, inclusion: { in: ->(_config) { Game.registry.keys } }

  # One-time grandfathering: servers the bot already lived in before game
  # selection existed are all New World communities. Runs only when the table
  # is empty, so freshly joining servers still go through selection.
  def self.backfill!(servers, game: 'new_world')
    return if any?

    servers = servers.values if servers.is_a?(Hash)
    servers.each { |server| create!(server_id: server.id.to_s, game: game) }
  end
end
