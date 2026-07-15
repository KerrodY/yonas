# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'

# Import PvP builds from CSV
def import_pvp_builds_from_csv(csv_filename, server_id)
  csv_file_path = Rails.root.join('lib', 'assets', 'seeds', csv_filename)

  unless File.exist?(csv_file_path)
    Rails.logger.debug { "Warning: CSV file not found at #{csv_file_path}" }
    return
  end

  imported_count = 0
  updated_count = 0
  error_count = 0

  Rails.logger.debug { "Importing PvP builds from #{csv_filename} for server #{server_id}..." }

  CSV.foreach(csv_file_path, headers: true) do |row|
    # Map CSV headers to database columns
    player_data = {
      server_id: server_id,
      player: row['Player']&.strip,
      role: row['Role']&.strip,
      weapon1: row['Weapon1']&.strip,
      weapon2: row['Weapon2']&.strip,
      armour_weight: row['ArmourWeight']&.strip,
      heartrune: row['Heartrune']&.strip,
      guest: row['Guest']&.strip&.downcase == 'true',
      discord_id: row['Discord']&.strip
    }

    # Skip rows with missing required fields
    if player_data[:player].blank? || player_data[:discord_id].blank?
      error_count += 1
      Rails.logger.debug "  Skipped: Missing player name or discord_id"
      next
    end

    # Find existing record or create new one
    player_build = PlayerBuild.find_by(
      server_id: server_id,
      discord_id: player_data[:discord_id]
    )

    if player_build
      player_build.update!(player_data)
      updated_count += 1
      Rails.logger.debug { "  Updated: #{player_data[:player]} (#{player_data[:discord_id]})" }
    else
      PlayerBuild.create!(player_data)
      imported_count += 1
      Rails.logger.debug { "  Imported: #{player_data[:player]} (#{player_data[:discord_id]})" }
    end
  rescue StandardError => e
    error_count += 1
    Rails.logger.debug { "  Error: #{e.message} for player: #{row['Player']}" }
  end

  Rails.logger.debug { "Import completed: #{imported_count} new, #{updated_count} updated, #{error_count} errors" }
end

# Seed PvP builds data
# Replace 'YOUR_SERVER_ID' with the actual Discord server ID
import_pvp_builds_from_csv('pvp_builds_1755334052.csv', '1404382016891519137')
