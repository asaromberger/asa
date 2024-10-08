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

ActiveRecord::Schema[7.0].define(version: 2024_09_01_232057) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "bridge_bbo_types", force: :cascade do |t|
    t.string "btype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bridge_bbos", force: :cascade do |t|
    t.date "date"
    t.string "bbo_id"
    t.decimal "score"
    t.decimal "rank"
    t.decimal "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bridge_bbo_type_id"
    t.integer "no_players"
  end

  create_table "bridge_boards", force: :cascade do |t|
    t.integer "board"
    t.boolean "nsvul"
    t.boolean "ewvul"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bridge_pairs", force: :cascade do |t|
    t.date "date"
    t.integer "pair"
    t.integer "player1_id"
    t.integer "player2_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bridge_players", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  create_table "bridge_results", force: :cascade do |t|
    t.date "date"
    t.integer "board"
    t.string "contract"
    t.string "by"
    t.integer "result"
    t.integer "ns"
    t.integer "nsscore"
    t.decimal "nspoints"
    t.integer "ew"
    t.integer "ewscore"
    t.decimal "ewpoints"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stype"
  end

  create_table "bridge_scores", force: :cascade do |t|
    t.date "date"
    t.integer "bridge_player_id"
    t.float "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pair"
  end

  create_table "bridge_tables", force: :cascade do |t|
    t.string "stype"
    t.integer "stable"
    t.integer "round"
    t.integer "ns"
    t.integer "ew"
    t.integer "board"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_expenses_accountmaps", force: :cascade do |t|
    t.string "account"
    t.string "ctype"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_expenses_categories", force: :cascade do |t|
    t.string "ctype"
    t.string "category"
    t.string "subcategory"
    t.string "tax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_expenses_inputs", force: :cascade do |t|
    t.date "date"
    t.string "pm"
    t.string "checkno"
    t.string "what"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_expenses_items", force: :cascade do |t|
    t.date "date"
    t.string "pm"
    t.string "checkno"
    t.integer "finance_expenses_what_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_expenses_what_maps", force: :cascade do |t|
    t.string "whatmap"
    t.integer "finance_expenses_what_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_expenses_whats", force: :cascade do |t|
    t.string "what"
    t.integer "finance_expenses_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_investments_accounts", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_investments_funds", force: :cascade do |t|
    t.string "fund"
    t.string "atype"
    t.boolean "closed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "finance_investments_account_id"
  end

  create_table "finance_investments_investments", force: :cascade do |t|
    t.integer "finance_investments_fund_id"
    t.date "date"
    t.decimal "value"
    t.decimal "shares"
    t.decimal "pershare"
    t.decimal "guaranteed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_investments_rebalances", force: :cascade do |t|
    t.integer "finance_investments_fund_id"
    t.decimal "target"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_investments_summaries", force: :cascade do |t|
    t.string "stype"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_investments_summary_contents", force: :cascade do |t|
    t.integer "finance_investments_account_id"
    t.integer "finance_investments_summary_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finance_trackings", force: :cascade do |t|
    t.date "date"
    t.text "what"
    t.float "amount"
    t.text "from"
    t.text "to"
    t.float "remaining"
    t.float "rate"
    t.integer "inc"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ptype"
    t.integer "finance_investments_account_id"
    t.integer "finance_investments_fund_id"
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

  create_table "genealogy_repos", force: :cascade do |t|
    t.string "name"
    t.string "addr"
    t.string "city"
    t.string "state"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genealogy_sources", force: :cascade do |t|
    t.string "title"
    t.string "abbreviation"
    t.string "published"
    t.string "refn"
    t.integer "genealogy_repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "health_data", force: :cascade do |t|
    t.integer "user_id"
    t.date "date"
    t.integer "resistance"
    t.integer "aerobic_calories"
    t.integer "weight"
    t.integer "steps"
    t.integer "flights"
    t.integer "miles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "active_calories"
    t.integer "resting_calories"
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
