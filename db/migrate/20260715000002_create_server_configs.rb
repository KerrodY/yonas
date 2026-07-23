# frozen_string_literal: true

class CreateServerConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :server_configs do |t|
      t.string :server_id, null: false, index: { unique: true }
      t.string :game, null: false

      t.timestamps
    end
  end
end
