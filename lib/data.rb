# frozen_string_literal: true

# Core bot configuration — everything here applies to every game community.
# Game-specific data (weapons, ranks, build fields, scrapers) lives in the
# game profiles under app/models/game/.
module DATA
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

  # --------------------------------------------------------------------------
  # Transition shims — every constant below now lives in Game::NewWorld and is
  # referenced here only until consumers switch to Game.for(server) (stage 3).
  # Delete this whole section when the last DATA:: game reference is gone.
  # --------------------------------------------------------------------------
  new_world = Game.find('new_world')

  WEAPONS = new_world.weapons.freeze
  WEAPONS_PARAMS = new_world.weapon_params.freeze
  REACT_ROLES = new_world.react_role_groups.freeze
  HEARTRUNES = new_world.heartrunes.freeze
  ARMOUR_WEIGHTS = new_world.armour_weights.freeze
  BUILDS = new_world.builds.freeze
  SERVERS = new_world.servers.freeze
  WEBSITE_SERVER_STATUS = new_world.status_page_url

  COMPANY_ROLES = new_world.hierarchy_roles.freeze
  CRAFTING_ROLES = new_world.game_roles.map { |role| role.merge(permissions: new_world.member_permissions).freeze }.freeze
  SERVER_ROLES = (COMPANY_ROLES + CRAFTING_ROLES).freeze
end
