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

ActiveRecord::Schema[7.0].define(version: 2023_04_01_021114) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "bridge_players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bridge_scores", force: :cascade do |t|
    t.date "date"
    t.integer "bridge_player_id"
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genealogy_children", force: :cascade do |t|
    t.integer "genealogy_individual_id"
    t.integer "genealogy_family_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genealogy_families", force: :cascade do |t|
    t.integer "genealogy_husband_id"
    t.integer "genealogy_wife_id"
    t.date "updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genealogy_individuals", force: :cascade do |t|
    t.integer "uid"
    t.integer "refn"
    t.string "sex"
    t.date "updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genealogy_info_sources", force: :cascade do |t|
    t.integer "genealogy_info_id"
    t.integer "genealogy_source_id"
    t.string "page"
    t.integer "quay"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genealogy_infos", force: :cascade do |t|
    t.integer "genealogy_individual_id"
    t.string "itype"
    t.date "date"
    t.string "place"
    t.hstore "data"
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "health_data", force: :cascade do |t|
    t.integer "user_id"
    t.date "date"
    t.integer "resistance"
    t.integer "calories"
    t.integer "weight"
    t.integer "steps"
    t.integer "flights"
    t.integer "miles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "music_playlists", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.integer "music_track_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "music_tracks", force: :cascade do |t|
    t.string "title"
    t.string "genre"
    t.string "artist"
    t.string "album"
    t.integer "track_number"
    t.integer "track_total"
    t.integer "duration"
    t.integer "file_size"
    t.string "location"
    t.integer "play_count"
    t.string "media_type"
    t.string "composer"
    t.integer "disc_number"
    t.integer "disc_total"
    t.string "comment"
    t.integer "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.integer "user_id"
    t.string "pkey"
    t.hstore "pvalue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "remember_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "application"
  end

end
