# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "challenges", :force => true do |t|
    t.integer  "challenger_id"
    t.integer  "challengee_id"
    t.integer  "game_id"
    t.integer  "result_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "challenges", ["challengee_id"], :name => "index_challenges_on_challengee_id"
  add_index "challenges", ["challenger_id"], :name => "index_challenges_on_challenger_id"
  add_index "challenges", ["game_id"], :name => "index_challenges_on_game_id"
  add_index "challenges", ["result_id"], :name => "index_challenges_on_result_id"

  create_table "games", :force => true do |t|
    t.string   "name",        :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  create_table "players", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "email"
  end

  create_table "players_results", :force => true do |t|
    t.integer "player_id", :null => false
    t.integer "result_id", :null => false
  end

  add_index "players_results", ["player_id"], :name => "index_players_results_on_player_id"
  add_index "players_results", ["result_id"], :name => "index_players_results_on_result_id"

  create_table "rating_history_events", :force => true do |t|
    t.integer  "rating_id",  :null => false
    t.integer  "value",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "rating_history_events", ["rating_id"], :name => "index_rating_history_events_on_rating_id"

  create_table "ratings", :force => true do |t|
    t.integer  "player_id",  :null => false
    t.integer  "game_id",    :null => false
    t.integer  "value",      :null => false
    t.boolean  "pro",        :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ratings", ["game_id"], :name => "index_ratings_on_game_id"
  add_index "ratings", ["player_id"], :name => "index_ratings_on_player_id"

  create_table "results", :force => true do |t|
    t.integer  "game_id",    :null => false
    t.integer  "loser_id",   :null => false
    t.integer  "winner_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "results", ["game_id"], :name => "index_results_on_game_id"
  add_index "results", ["loser_id"], :name => "index_results_on_loser_id"
  add_index "results", ["winner_id"], :name => "index_results_on_winner_id"

end
