class Release005 < ActiveRecord::Migration
  def up
    remove_column :players, :gravatar
    add_column :players, :email, :string
  end

  def down
  end
end
