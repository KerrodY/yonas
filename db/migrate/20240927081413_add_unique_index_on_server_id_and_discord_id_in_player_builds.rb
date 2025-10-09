class AddUniqueIndexOnServerIdAndDiscordIdInPlayerBuilds < ActiveRecord::Migration[7.2]
  def change
    add_index :player_builds, [:server_id, :discord_id], unique: true
    change_column_null :player_builds, :discord_id, false
    change_column_null :player_builds, :heartrune, false
  end
end
