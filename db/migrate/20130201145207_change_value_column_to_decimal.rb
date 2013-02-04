class ChangeValueColumnToDecimal < ActiveRecord::Migration
  def up
    change_column :ratings, :value, :decimal, {:scale => 4, :precision => 10}
    change_column :rating_history_events, :value, :decimal, {:scale => 4, :precision => 10}
  end

  def down
    change_column :ratings, :value, :integer
    change_column :rating_history_events, :value, :integer
  end
end
