class CreateCompanyApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :company_applications do |t|
      t.string :server_id, null: false
      t.string :discord_name, null: false
      t.string :status, null: false
      t.string :years_of_experience, null: false
      t.string :pvp_player, null: false
      t.string :ign, null: false
      t.string :role, null: false
      t.string :online_at_launch, null: false

      t.timestamps
    end
  end
end
