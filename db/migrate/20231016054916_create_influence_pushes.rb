class CreateInfluencePushes < ActiveRecord::Migration[7.1]
  def change
    create_table :influence_pushes do |t|
      t.string :player
      t.text :role
      t.text :armour_weight

      t.timestamps
    end
  end
end
