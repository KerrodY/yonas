# frozen_string_literal: true

class Feedback < ApplicationRecord
  validates :message, presence: true
  validates :discord_id, presence: true
  validates :server_id, presence: true
end
