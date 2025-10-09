class CreatePlayerBuilds < ActiveRecord::Migration[7.1]
  def change
    create_table :player_builds do |t|
      t.string :server_id, null: false
      t.string :player, null: false
      t.string :weapon_1, null: false
      t.string :weapon_2, null: false
      t.string :armour_weight, null: false
      t.string :discord_id
      t.timestamps
    end
  end
end
