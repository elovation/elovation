class Release007 < ActiveRecord::Migration
  def up
    add_column :games, :description, :string
  end

  def down
    remove_column :games, :description
  end
end
