class AddRolesToPlayerBuilds < ActiveRecord::Migration[7.2]
  def change
    add_column :player_builds, :role, :string, null: false
  end
end
