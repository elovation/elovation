class Release004 < ActiveRecord::Migration
  def up
    add_index :players_results, :player_id
    add_index :players_results, :result_id

    add_index :rating_history_events, :rating_id

    add_index :ratings, :player_id
    add_index :ratings, :game_id

    add_index :results, :game_id
    add_index :results, :loser_id
    add_index :results, :winner_id
  end

  def down
  end
end
