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

ActiveRecord::Schema.define(:version => 1) do

  create_table "games", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "players", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "players_results", :force => true do |t|
    t.integer "player_id", :null => false
    t.integer "result_id", :null => false
  end

  create_table "ratings", :force => true do |t|
    t.integer  "player_id",  :null => false
    t.integer  "game_id",    :null => false
    t.integer  "value",      :null => false
    t.boolean  "pro",        :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "results", :force => true do |t|
    t.integer  "game_id",    :null => false
    t.integer  "loser_id",   :null => false
    t.integer  "winner_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
