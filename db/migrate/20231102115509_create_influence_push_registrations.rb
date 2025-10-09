class CreateInfluencePushRegistrations < ActiveRecord::Migration[7.1]
  def change
    create_table :influence_push_registrations do |t|
      t.string :player,  null: false
      t.timestamps
    end
  end
end
