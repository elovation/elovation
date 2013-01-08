class DropWinnerAndLoser < ActiveRecord::Migration
  def up
    remove_column :results, :winner_id
    remove_column :results, :loser_id
    drop_table :players_results
  end

  def down
  end
end
