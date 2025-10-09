class CompanyApplication < ApplicationRecord
  validates :server_id, :discord_name, :status, :years_of_experience, :pvp_player, :ign, :role, presence: true
end
