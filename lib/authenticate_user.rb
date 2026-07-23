# frozen_string_literal: true

# Authorizes slash commands against the acting server's game profile. Commands
# request a generic access level (:admin, :staff, :helper, :member, :guest, or
# :any); the profile maps that level to the game's own role names.
module AuthenticateUser
  DENIED_MESSAGE = 'You do not have permission for this command, ask staff if you feel you should'
  NO_GAME_MESSAGE = 'This server has not been set up yet. Ask an admin to run the setup.'

  # Ranked check by default: `level` and every level above it are allowed.
  # Pass exact: true to allow only the given level (e.g. guests only for /apply).
  def self.authorized?(event, level = :member, exact: false)
    game = Game.for(event.server)
    unless game
      event.respond(content: NO_GAME_MESSAGE, ephemeral: true)
      return false
    end

    allowed = game.role_names_for(level, exact: exact)
    return true if event.user.roles.any? { |role| allowed.include?(role.name) }

    event.respond(content: DENIED_MESSAGE, ephemeral: true)
    false
  end
end
