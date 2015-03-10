class Release008 < ActiveRecord::Migration
  class Player < ActiveRecord::Base; end

  def up
    add_column :players, :display_game_count, :boolean

    Player.update_all(
      display_game_count: true
    )
  end

  def down
  end
end
