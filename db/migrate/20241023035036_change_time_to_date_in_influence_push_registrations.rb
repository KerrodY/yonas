class ChangeTimeToDateInInfluencePushRegistrations < ActiveRecord::Migration[7.2]
  def up
    change_column :influence_push_registrations, :time, :date
  end

  def down
    change_column :influence_push_registrations, :time, :datetime
  end
end