# frozen_string_literal: true

# Game profile for Amazon's New World. Currently a thin delegation layer over
# the DATA constants — the data itself migrates here in a follow-up change.
class Game::NewWorld < Game::Base
  def display_name
    'New World'
  end

  def game_roles
    DATA::CRAFTING_ROLES
  end

  def weapons
    DATA::WEAPONS
  end

  def weapon_params
    DATA::WEAPONS_PARAMS
  end

  def react_role_groups
    DATA::REACT_ROLES
  end

  def heartrunes
    DATA::HEARTRUNES
  end

  def armour_weights
    DATA::ARMOUR_WEIGHTS
  end

  def builds
    DATA::BUILDS
  end

  def servers
    DATA::SERVERS
  end

  def status_page_url
    DATA::WEBSITE_SERVER_STATUS
  end

  def notifiers
    [NewWorldNotifications, PlayerBuildsTask]
  end
end
