class ResultService
  def self.create(game, params)
    result = game.results.build

    current_rank = Team::FIRST_PLACE_RANK
    (params[:teams] || {}).each do |_, team|
      result.teams.build rank: current_rank, player_ids: team[:players]
      if team[:relation] != "ties"
        current_rank = current_rank + 1
      end
    end

    if result.valid?
      Result.transaction do
        game.rater.update_ratings game, result.teams

        result.save!

        OpenStruct.new(
          :success? => true,
          :result => result
        )
      end
    else
      OpenStruct.new(
        :success? => false,
        :result => result
      )
    end
  end

  def self.destroy(result)
    return OpenStruct.new(:success? => false) unless result.most_recent?

    Result.transaction do
      result.players.each do |player|
        player.rewind_rating!(result.game)
      end

      result.destroy

      OpenStruct.new(:success? => true)
    end
  end
end
