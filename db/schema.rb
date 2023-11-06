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

ActiveRecord::Schema[7.0].define(version: 2023_11_04_231848) do
  # These are extensions that must be enabled in order to support this database
  enable_extension("plpgsql")

  create_table("games", force: :cascade) do |t|
    t.string("name", null: false)
    t.string("rating_type")
    t.integer("min_number_of_teams")
    t.integer("max_number_of_teams")
    t.integer("min_number_of_players_per_team")
    t.integer("max_number_of_players_per_team")
    t.boolean("allow_ties")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
  end

  create_table("memberships", force: :cascade) do |t|
    t.bigint("player_id", null: false)
    t.bigint("team_id", null: false)
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.index(["player_id"], name: "index_memberships_on_player_id")
    t.index(["team_id"], name: "index_memberships_on_team_id")
  end

  create_table("players", force: :cascade) do |t|
    t.string("name", null: false)
    t.string("email")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
  end

  create_table("rating_history_events", force: :cascade) do |t|
    t.bigint("rating_id", null: false)
    t.integer("value", null: false)
    t.float("trueskill_mean")
    t.float("trueskill_deviation")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.index(["rating_id"], name: "index_rating_history_events_on_rating_id")
  end

  create_table("ratings", force: :cascade) do |t|
    t.bigint("game_id", null: false)
    t.bigint("player_id", null: false)
    t.integer("value", null: false)
    t.boolean("pro", null: false)
    t.float("trueskill_mean")
    t.float("trueskill_deviation")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.index(["game_id"], name: "index_ratings_on_game_id")
    t.index(["player_id"], name: "index_ratings_on_player_id")
  end

  create_table("results", force: :cascade) do |t|
    t.bigint("game_id", null: false)
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.index(["game_id"], name: "index_results_on_game_id")
  end

  create_table("teams", force: :cascade) do |t|
    t.integer("rank")
    t.bigint("result_id")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.integer("score")
    t.index(["result_id"], name: "index_teams_on_result_id")
  end

  add_foreign_key("memberships", "players")
  add_foreign_key("memberships", "teams")
  add_foreign_key("rating_history_events", "ratings")
  add_foreign_key("ratings", "games")
  add_foreign_key("ratings", "players")
  add_foreign_key("results", "games")
  add_foreign_key("teams", "results")
end
