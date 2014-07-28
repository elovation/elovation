class Release001 < ActiveRecord::Migration
  def up
    create_table :games do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :players do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :players_results do |t|
      t.integer :player_id, null: false
      t.integer :result_id, null: false
    end

    create_table :ratings do |t|
      t.integer :player_id, null: false
      t.integer :game_id, null: false
      t.integer :value, null: false
      t.boolean :pro, null: false

      t.timestamps
    end

    create_table :results do |t|
      t.integer :game_id, null: false
      t.integer :loser_id, null: false
      t.integer :winner_id, null: false

      t.timestamps
    end
  end

  def down
  end
end
