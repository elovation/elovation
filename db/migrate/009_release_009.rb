class Release009 < ActiveRecord::Migration
  def change
    create_table :flairs do |t|
      t.string :name, null: false
    end

    change_table :players do |t|
      t.belongs_to :flair
    end

    reversible do |change|
      change.up do
        add_attachment :flairs, :avatar
      end

      change.down do
        remove_attachment :flairs, :avatar
      end
    end
  end
end
