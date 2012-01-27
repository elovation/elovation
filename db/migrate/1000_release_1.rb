class Release1 < ActiveRecord::Migration
  def up
    create_table :players do |t|
    end

    create_table :games do |t|
    end
  end

  def down
  end
end
