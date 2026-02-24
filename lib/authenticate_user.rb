# frozen_string_literal: true

module AuthenticateUser
  ROLE_GROUPS = {
    any: %w[governor officer consul member guest],
    governor: %w[governor],
    admin: %w[governor consul],
    staff: %w[governor officer consul],
    member: %w[member governor officer consul],
    guest: %w[guest]
  }

  def self.authorized?(event, group = :member)
    unless event.user.roles.any? { |role| ROLE_GROUPS[group].include?(role.name.downcase) }
      event.respond(content: "You do not have permission for this command, ask staff if you feel you should", ephemeral: true)
      return false
    end

    true
  end
end
