class Release1 < ActiveRecord::Migration
  def up
    create_table :players do |t|
      t.string :name

      t.timestamps
    end

    create_table :games do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def down
  end
end
