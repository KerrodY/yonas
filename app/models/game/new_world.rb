# frozen_string_literal: true

# Game profile for Amazon's New World. Owns everything New World-specific:
# rank names (companies!), weapons, crafting disciplines, build fields,
# world list, and the scrapers that watch the official site.
class Game::NewWorld < Game::Base
  def display_name
    'New World'
  end

  # New World companies are led by a Governor and their Consuls, with Officers
  # below them. Governor and Consul both hold server-admin trust.
  def hierarchy_roles
    [
      { name: 'Governor', colour: 0x9B59B6, permissions: administrator_permissions },
      { name: 'Consul', colour: 0xE74C3C, permissions: management_permissions },
      { name: 'Officer', colour: 0xF39C12, permissions: officer_permissions },
      { name: 'Member', colour: 0x3498DB, permissions: member_permissions },
      { name: 'Guest', colour: 0x95A5A6, permissions: guest_permissions }
    ]
  end

  def access_roles
    {
      admin: %w[Governor Consul],
      staff: %w[Officer],
      member: %w[Member],
      guest: %w[Guest]
    }
  end

  def game_roles
    [
      { name: 'Weaponsmithing', emoji: '⚒️', colour: 0x8E44AD },
      { name: 'Armoring', emoji: '🛡️', colour: 0xC0392B },
      { name: 'Engineering', emoji: '⚙️', colour: 0xD35400 },
      { name: 'Jewelcrafting', emoji: '💎', colour: 0x2980B9 },
      { name: 'Arcana', emoji: '🔮', colour: 0x7F8C8D },
      { name: 'Cooking', emoji: '🍳', colour: 0x1ABC9C },
      { name: 'Furnishing', emoji: '🪑', colour: 0x2ECC71 }
    ]
  end

  def weapons
    [
      { name: 'Sword and Shield', emoji: '🛡️' },
      { name: 'Sword', emoji: '⚔️' },
      { name: 'Rapier', emoji: '🤺' },
      { name: 'Hatchet', emoji: '🪓' },
      { name: 'Flail and Shield', emoji: '⛓️' },
      { name: 'Spear', emoji: '🔱' },
      { name: 'Great Axe', emoji: '⚒️' },
      { name: 'Great Sword', emoji: '🗡️' },
      { name: 'War Hammer', emoji: '🔨' },
      { name: 'Bow', emoji: '🏹' },
      { name: 'Musket', emoji: '🔫' },
      { name: 'Blunderbuss', emoji: '💥' },
      { name: 'Fire Staff', emoji: '🔥' },
      { name: 'Ice Gauntlet', emoji: '❄️' },
      { name: 'Void Gauntlet', emoji: '🌌' },
      { name: 'Life Staff', emoji: '✨' }
    ]
  end

  def weapon_params
    weapons.to_h { |weapon| [weapon[:name], weapon[:name]] }
  end

  def react_role_groups
    [
      { title: 'Select your weapon roles', roles: weapons },
      { title: 'Select your crafting roles', roles: game_roles }
    ]
  end

  def heartrunes
    {
      'Cannon Blast' => 'cannon_blast', 'Dark Ascent' => 'dark_ascent', 'Grasping Vines' => 'grasping_vines',
      'Detonate' => 'detonate', 'Stoneform' => 'stoneform', 'Bile Bomb' => 'bile_bomb',
      'Fire Storm' => 'fire_storm', 'The Devourer' => 'the_devourer', 'Primal Fury' => 'primal_fury'
    }
  end

  def armour_weights
    { 'Light' => 'light', 'Medium' => 'medium', 'Heavy' => 'heavy' }
  end

  def builds
    { 'DPS' => 'dps', 'Ranged DPS' => 'ranged_dps', 'Tank' => 'tank', 'Mage' => 'mage', 'Healer' => 'healer' }
  end

  def servers
    {
      'El Dorado': 'El Dorado', Kronomo: 'Kronomo', Hudsonland: 'Hudsonland', Pangea: 'Pangea', Valhalla: 'Valhalla ',
      Tumtum: 'Tumtum', Devaloka: 'Devaloka', Nihal: 'Nihal', Aries: 'Aries', Bifrost: 'Bifrost', Nysa: 'Nysa',
      Mardi: 'Mardi', Delos: 'Delos', Taiyi: 'Taiyi'
    }
  end

  def status_page_url
    'https://www.newworld.com/en-us/support/server-status'
  end

  def notifiers
    [NewWorldNotifications, PlayerBuildsTask]
  end
end
