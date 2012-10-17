class Release006 < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.integer :challenger_id
      t.integer :challengee_id
      t.integer :game_id
      t.integer :result_id

      t.timestamps
    end

    add_index :challenges, :challenger_id
    add_index :challenges, :challengee_id
    add_index :challenges, :game_id
    add_index :challenges, :result_id
  end
end
