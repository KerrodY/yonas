class PlayerBuild < ActiveRecord::Migration[7.1]
  def change
    add_column :player_builds, :heartrune, :string
  end
end
