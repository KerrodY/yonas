class AddTerritoryToInfluencePushRegistrations < ActiveRecord::Migration[7.2]
  def change
    add_column :influence_push_registrations, :territory, :string
    add_column :influence_push_registrations, :time, :datetime
    rename_column :influence_push_registrations, :player, :discord_id
  end
end
