class UpdateInfluencePushRegistration < ActiveRecord::Migration[7.1]
  def change
    add_column :influence_push_registrations, :server_id, :string, null: false
  end
end
