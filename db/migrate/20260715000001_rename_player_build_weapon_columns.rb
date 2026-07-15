# frozen_string_literal: true

class RenamePlayerBuildWeaponColumns < ActiveRecord::Migration[8.1]
  def change
    # rubocop:disable Naming/VariableNumber -- the old column names are historical fact
    rename_column :player_builds, :weapon_1, :weapon1
    rename_column :player_builds, :weapon_2, :weapon2
    # rubocop:enable Naming/VariableNumber
  end
end
