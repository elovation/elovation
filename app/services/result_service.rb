class ResultService
  def self.create(game, params)
    players = []
    begin
      players.push Player.find(params[:winner_id])
      players.push Player.find(params[:loser_id])
    rescue ActiveRecord::RecordNotFound
    end

    result = game.results.build(
      :winner_id => params[:winner_id],
      :loser_id => params[:loser_id],
      :players => players
    )

    if result.valid?
      Result.transaction do
        RatingService.update(game, result.winner, result.loser)
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
      [result.winner, result.loser].each do |player|
        player.rewind_rating!(result.game)
      end

      result.destroy

      OpenStruct.new(:success? => true)
    end
  end
end
