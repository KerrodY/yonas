# frozen_string_literal: true

# Namespace for game profiles. A game profile packages everything about a
# specific game that Yonas needs: roles, reaction-role groups, build fields,
# and notification scrapers. The rest of the app talks to `Game.current`
# and never needs to know which game it's serving.
module Game
  # The active game profile. Hardcoded to New World for now — when multi-game
  # support lands, this becomes a per-Discord-server lookup instead.
  def self.current
    @current ||= Game::NewWorld.new
  end
end
