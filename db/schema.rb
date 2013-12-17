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

ActiveRecord::Schema.define(:version => 20131217154722) do

  create_table "games", :force => true do |t|
    t.string   "name",                           :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "rating_type"
    t.integer  "min_number_of_teams"
    t.integer  "max_number_of_teams"
    t.integer  "min_number_of_players_per_team"
    t.integer  "max_number_of_players_per_team"
    t.boolean  "allow_ties"
  end

  create_table "players", :force => true do |t|
    t.string   "name",                                   :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email"
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin"
  end

  add_index "players", ["email"], :name => "index_players_on_email", :unique => true
  add_index "players", ["reset_password_token"], :name => "index_players_on_reset_password_token", :unique => true

  create_table "players_teams", :force => true do |t|
    t.integer "player_id"
    t.integer "team_id"
  end

  create_table "rating_history_events", :force => true do |t|
    t.integer  "rating_id",           :null => false
    t.integer  "value",               :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.float    "trueskill_mean"
    t.float    "trueskill_deviation"
  end

  add_index "rating_history_events", ["rating_id"], :name => "index_rating_history_events_on_rating_id"

  create_table "ratings", :force => true do |t|
    t.integer  "player_id",           :null => false
    t.integer  "game_id",             :null => false
    t.integer  "value",               :null => false
    t.boolean  "pro",                 :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.float    "trueskill_mean"
    t.float    "trueskill_deviation"
  end

  add_index "ratings", ["game_id"], :name => "index_ratings_on_game_id"
  add_index "ratings", ["player_id"], :name => "index_ratings_on_player_id"

  create_table "results", :force => true do |t|
    t.integer  "game_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "results", ["game_id"], :name => "index_results_on_game_id"

  create_table "teams", :force => true do |t|
    t.integer  "rank"
    t.integer  "result_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
