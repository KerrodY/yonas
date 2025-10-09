# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_11_111701) do
  create_table "company_applications", force: :cascade do |t|
    t.string "server_id", null: false
    t.string "discord_name", null: false
    t.string "status", null: false
    t.string "years_of_experience", null: false
    t.string "pvp_player", null: false
    t.string "ign", null: false
    t.string "role", null: false
    t.string "online_at_launch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "extra_info"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text "message"
    t.string "display_name"
    t.string "discord_id"
    t.string "server_id"
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "influence_push_registrations", force: :cascade do |t|
    t.string "discord_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "server_id", null: false
    t.string "territory"
    t.date "time"
  end

  create_table "news_articles", force: :cascade do |t|
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "player_builds", force: :cascade do |t|
    t.string "server_id", null: false
    t.string "player", null: false
    t.string "weapon_1", null: false
    t.string "weapon_2", null: false
    t.string "armour_weight", null: false
    t.string "discord_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "heartrune", null: false
    t.string "role", null: false
    t.boolean "guest", default: false, null: false
    t.index ["player", "server_id"], name: "index_player_builds_on_player_and_server_id", unique: true
    t.index ["server_id", "discord_id"], name: "index_player_builds_on_server_id_and_discord_id", unique: true
  end

  create_table "pvp_events", force: :cascade do |t|
    t.string "player"
    t.text "role"
    t.text "armour_weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "update_notifications", force: :cascade do |t|
    t.string "channel_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_update_notifications_on_channel_id", unique: true
  end
end
