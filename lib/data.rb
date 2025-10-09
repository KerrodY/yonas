# frozen_string_literal: true

module DATA
  SERVERS = {
    'El Dorado': "El Dorado", Kronomo: "Kronomo", Hudsonland: "Hudsonland", Pangea: "Pangea", Valhalla: "Valhalla ",
    Tumtum: "Tumtum", Devaloka: "Devaloka", Nihal: "Nihal", Aries: "Aries", Bifrost: "Bifrost", Nysa: "Nysa",
    Mardi: "Mardi", Delos: "Delos", Taiyi: "Taiyi"
  }.freeze

  WEBSITE_SERVER_STATUS = 'https://www.newworld.com/en-us/support/server-status'

  FEEDBACK_EMOJIS = %w[👍 ✅ 🙏 💯 👌 🎯 ✨ 🔥 💪 ⭐ 🚀 💎 🎉 🏆 🌟 💝 🎊 👏 🤝 💚 🧡 💜 ❤️ 🤩 😎 🥳 🙌 👑 🎵 🎸].freeze

  CHANNELS = {
    GENERAL: {
      name: '🤖┃general',
      type: 0,
      topic: 'Communicate with Yonas here!',
      permission_overwrites: [
        { role: '@everyone', deny: %i[read_messages send_messages] },
        { role: 'Member', allow: %i[read_messages send_messages] },
        { role: 'Officer', allow: %i[read_messages send_messages] },
        { role: 'Consul', allow: %i[read_messages send_messages] }
      ]
    }.freeze,
    ROLES: {
      name: '🎲┃roles',
      type: 0,
      topic: 'Select your roles!',
      permission_overwrites: [
        { role: '@everyone', deny: %i[read_messages send_messages] },
        { role: 'Member', allow: %i[read_messages] },
        { role: 'Officer', allow: %i[read_messages] },
        { role: 'Consul', allow: %i[read_messages] }
      ]
    }.freeze,
    ANNOUNCEMENTS: {
      name: '📢┃announcements',
      type: 0,
      topic: 'Yonas announcements',
      permission_overwrites: [
        { role: '@everyone', deny: %i[send_messages read_messages] },
        { role: 'Member', allow: %i[read_messages] },
        { role: 'Officer', allow: %i[read_messages send_messages] },
        { role: 'Consul', allow: %i[read_messages send_messages] }
      ]
    }.freeze,
    ADMIN: {
      name: '🏅┃admin',
      type: 0,
      topic: 'Admin channel for Yonas admin commands and updates',
      permission_overwrites: [
        { role: '@everyone', deny: %i[read_messages] },
        { role: 'Officer', allow: %i[read_messages send_messages] },
        { role: 'Consul', allow: %i[read_messages send_messages] }
      ]
    }.freeze,
    WELCOME: {
      name: '👋┃welcome',
      type: 0,
      topic: 'Welcome channel for new joiners'
    }.freeze,
    APPLICATIONS: {
      name: '📝┃applications',
      type: 0,
      topic: 'Applications relating to the company',
      permission_overwrites: [
        { role: '@everyone', deny: %i[read_messages] },
        { role: 'Officer', allow: %i[read_messages send_messages] },
        { role: 'Consul', allow: %i[read_messages send_messages] }
      ]
    }.freeze,
    FEEDBACK: {
      name: '📧┃yonas-feedback',
      type: 0,
      topic: 'Early Access channel to Provide feedback about Yonas straight to the developer',
      permission_overwrites: [
        { role: '@everyone', deny: %i[read_messages send_messages] },
        { role: 'Member', allow: %i[read_messages send_messages] },
        { role: 'Officer', allow: %i[read_messages send_messages] },
        { role: 'Consul', allow: %i[read_messages send_messages] }
      ]
    }.freeze,
    JOIN_TO_CREATE: {
      name: '👄┃Join to Create',
      type: 2,
      permission_overwrites: [
        { role: '@everyone', deny: %i[read_messages send_messages] },
        { role: 'Member', allow: %i[read_messages send_messages] },
        { role: 'Officer', allow: %i[read_messages send_messages] },
        { role: 'Consul', allow: %i[read_messages send_messages] }
      ]
    }.freeze
  }.freeze

  YONAS_CHANNELS = [
    CHANNELS[:GENERAL],
    CHANNELS[:ANNOUNCEMENTS],
    CHANNELS[:WELCOME],
    CHANNELS[:ROLES],
    CHANNELS[:ADMIN],
    CHANNELS[:APPLICATIONS],
    CHANNELS[:FEEDBACK],
    CHANNELS[:JOIN_TO_CREATE]
  ].freeze

  # Define base permissions
  GUEST_PERMISSIONS = %i[read_messages send_messages connect speak use_voice_activity use_slash_commands request_to_speak use_public_threads use_private_threads send_messages_in_threads].freeze
  MEMBER_PERMISSIONS = %i[create_instant_invite add_reactions stream embed_links attach_files read_message_history use_external_emoji use_embedded_activities].freeze
  OFFICER_PERMISSIONS = %i[move_members manage_nicknames manage_messages mute_members deafen_members].freeze
  CONSUL_PERMISSIONS = %i[priority_speaker manage_messages kick_members ban_members manage_channels manage_roles].freeze
  GOVERNOR_PERMISSIONS = %i[administrator].freeze

  SERVER_ROLE_PERMISSIONS = {
    GUEST: GUEST_PERMISSIONS,
    MEMBER: GUEST_PERMISSIONS + MEMBER_PERMISSIONS,
    OFFICER: GUEST_PERMISSIONS + MEMBER_PERMISSIONS + OFFICER_PERMISSIONS,
    CONSUL: GUEST_PERMISSIONS + MEMBER_PERMISSIONS + OFFICER_PERMISSIONS + CONSUL_PERMISSIONS,
    GOVERNOR: GOVERNOR_PERMISSIONS
  }.freeze

  # Server roles with permissions and colors
  COMPANY_ROLES = [
    { name: 'Governor', colour: 0x9B59B6, permissions: SERVER_ROLE_PERMISSIONS[:GOVERNOR] }.freeze,
    { name: 'Consul', colour: 0xE74C3C, permissions: SERVER_ROLE_PERMISSIONS[:CONSUL] }.freeze,
    { name: 'Officer', colour: 0xF39C12, permissions: SERVER_ROLE_PERMISSIONS[:OFFICER] }.freeze,
    { name: 'Member', colour: 0x3498DB, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze,
    { name: 'Guest', colour: 0x95A5A6, permissions: SERVER_ROLE_PERMISSIONS[:GUEST] }.freeze
  ].freeze

  CRAFTING_ROLES = [
    { name: 'Weaponsmithing', emoji: '⚒️', colour: 0x8E44AD, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze,
    { name: 'Armoring', emoji: '🛡️', colour: 0xC0392B, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze,
    { name: 'Engineering', emoji: '⚙️', colour: 0xD35400, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze,
    { name: 'Jewelcrafting', emoji: '💎', colour: 0x2980B9, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze,
    { name: 'Arcana', emoji: '🔮', colour: 0x7F8C8D, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze,
    { name: 'Cooking', emoji: '🍳', colour: 0x1ABC9C, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze,
    { name: 'Furnishing', emoji: '🪑', colour: 0x2ECC71, permissions: SERVER_ROLE_PERMISSIONS[:MEMBER] }.freeze
  ].freeze

  SERVER_ROLES = (COMPANY_ROLES + CRAFTING_ROLES).freeze

  WEAPONS = [
    { name: 'Sword and Shield', emoji: '🛡️' },
    { name: 'Sword', emoji: '⚔️' },
    { name: 'Rapier', emoji: '🗡️' },
    { name: 'Hatchet', emoji: '🪓' },
    { name: 'Flail and Shield', emoji: '⛓️' },
    { name: 'Spear', emoji: '🔱' },
    { name: 'Great Axe', emoji: '🪓' },
    { name: 'Great Sword', emoji: '⚔️' },
    { name: 'War Hammer', emoji: '🔨' },
    { name: 'Bow', emoji: '🏹' },
    { name: 'Musket', emoji: '🔫' },
    { name: 'Blunderbuss', emoji: '💥' },
    { name: 'Fire Staff', emoji: '🔥' },
    { name: 'Ice Gauntlet', emoji: '❄️' },
    { name: 'Void Gauntlet', emoji: '🌌' },
    { name: 'Life Staff', emoji: '✨' }
  ].freeze

  WEAPONS_PARAMS = WEAPONS.to_h { |weapon| [weapon[:name], weapon[:name]] }.freeze

  HEARTRUNES = {
    'Cannon Blast' => 'cannon_blast', 'Dark Ascent' => 'dark_ascent', 'Grasping Vines' => 'grasping_vines', 'Detonate' => 'detonate',
    'Stoneform' => 'stoneform', 'Bile Bomb' => 'bile_bomb', 'Fire Storm' => 'fire_storm', 'The Devourer' => 'the_devourer',
    'Primal Fury' => 'primal_fury'
  }.freeze

  ARMOUR_WEIGHTS = { 'Light' => 'light', 'Medium' => 'medium', 'Heavy' => 'heavy' }.freeze

  BUILDS = { 'DPS' => 'dps', 'Ranged DPS' => 'ranged_dps', 'Tank' => 'tank', 'Mage' => 'mage', 'Healer' => 'healer' }.freeze

  REACT_ROLES = [WEAPONS, CRAFTING_ROLES].freeze
end
