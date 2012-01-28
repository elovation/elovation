class Release100 < ActiveRecord::Migration
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

    create_table :results do |t|
      t.timestamps
    end
  end

  def down
  end
end
