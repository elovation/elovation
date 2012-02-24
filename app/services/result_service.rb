class ResultService
  def self.create(game, params)
    winner = Player.find(params[:winner_id])
    loser = Player.find(params[:loser_id])

    result = game.results.build(
      :winner => winner,
      :loser => loser,
      :players => [winner, loser]
    )

    if result.valid?
      Result.transaction do
        RatingService.update(game, winner, loser)
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
    Result.transaction do
      [result.winner, result.loser].each do |player|
        player.rewind_rating!(result.game)
      end

      result.destroy
    end
  end
end
