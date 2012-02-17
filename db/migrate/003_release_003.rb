class Release003 < ActiveRecord::Migration
  def up
    change_table :players do |t|
      t.string :gravatar
    end
  end

  def down
  end
end
