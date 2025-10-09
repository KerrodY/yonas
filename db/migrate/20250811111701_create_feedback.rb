class CreateFeedback < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.text :message
      t.string :display_name
      t.string :discord_id
      t.string :server_id
      t.string :channel_id

      t.timestamps
    end
  end
end
