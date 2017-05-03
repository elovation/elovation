class Release003 < ActiveRecord::Migration[4.2]
  def up
    change_table :players do |t|
      t.string :gravatar
    end
  end

  def down
  end
end
