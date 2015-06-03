class Release008 < ActiveRecord::Migration
  class Player < ActiveRecord::Base; end

  def change
    add_column :players, :display_game_count, :boolean

    Player.update_all(
      display_game_count: true
    )
  end
end
