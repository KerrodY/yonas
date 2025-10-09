class AddGuestToPvpBuilds < ActiveRecord::Migration[7.2]
  def change
    add_column :player_builds, :guest, :boolean, default: false, null: false
  end
end
