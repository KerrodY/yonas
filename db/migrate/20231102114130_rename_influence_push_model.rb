class RenameInfluencePushModel < ActiveRecord::Migration[7.1]
  def change
    # Rename the database table from 'products' to 'items'
    rename_table :influence_pushes, :pvp_events
  end
end
