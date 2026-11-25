# frozen_string_literal: true

class AddThemeToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :theme, :string
  end
end
