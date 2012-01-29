class ResultService
  def self.build_result(game, params)
    game.results.build(
      :winner_id => params[:winner_id],
      :player_ids => [params[:player_1_id], params[:player_2_id]]
    )
  end
end
