class ResultService
  def self.create(game, params)
    result = game.results.build(
      :winner_id => params[:winner_id],
      :loser_id => params[:loser_id],
      :player_ids => [params[:winner_id], params[:loser_id]]
    )

    if result.save
      OpenStruct.new(
        :success? => true,
        :result => result
      )
    end
  end
end
