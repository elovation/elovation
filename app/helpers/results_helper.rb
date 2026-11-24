# frozen_string_literal: true

module ResultsHelper
  def player_options
    Player.order('name ASC').all.map { |player| [player.name, player.id] }
  end
end
