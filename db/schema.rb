# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170425005600) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string   "name",                                          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rating_type"
    t.integer  "min_number_of_teams"
    t.integer  "max_number_of_teams"
    t.integer  "min_number_of_players_per_team"
    t.integer  "max_number_of_players_per_team"
    t.boolean  "allow_ties"
    t.boolean  "active",                         default: true
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "slack_id"
  end

  create_table "players_teams", force: :cascade do |t|
    t.integer "player_id"
    t.integer "team_id"
  end

  create_table "rating_history_events", force: :cascade do |t|
    t.integer  "rating_id",           null: false
    t.integer  "value",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "trueskill_mean"
    t.float    "trueskill_deviation"
    t.index ["rating_id"], name: "index_rating_history_events_on_rating_id", using: :btree
  end

  create_table "ratings", force: :cascade do |t|
    t.integer  "player_id",           null: false
    t.integer  "game_id",             null: false
    t.integer  "value",               null: false
    t.boolean  "pro",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "trueskill_mean"
    t.float    "trueskill_deviation"
    t.index ["game_id"], name: "index_ratings_on_game_id", using: :btree
    t.index ["player_id"], name: "index_ratings_on_player_id", using: :btree
  end

  create_table "results", force: :cascade do |t|
    t.integer  "game_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["game_id"], name: "index_results_on_game_id", using: :btree
  end

  create_table "slack_authorizations", force: :cascade do |t|
    t.string "access_token"
    t.string "scope"
    t.string "user_id"
    t.string "team_name"
    t.string "team_id"
    t.index ["team_id"], name: "index_slack_authorizations_on_team_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.integer  "rank"
    t.integer  "result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
