class AddUniqueIndexToPlayerBuild < ActiveRecord::Migration[7.1]
  def change
    add_index :player_builds, [:player, :server_id], unique: true
  end
end
