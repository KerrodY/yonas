class CreateUpdateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :update_notifications do |t|
      t.string :channel_id, null: false

      t.timestamps
    end

    add_index :update_notifications, :channel_id, unique: true
  end
end
