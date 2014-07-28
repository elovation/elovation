class Release002 < ActiveRecord::Migration
  def up
    create_table :rating_history_events do |t|
      t.integer :rating_id, null: false
      t.integer :value, null: false

      t.timestamps
    end
  end

  def down
  end
end
