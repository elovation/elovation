class ResultService
  def self.build_result(game, params)
    game.results.build(
      :winner_id => params[:winner_id],
      :loser_id => params[:loser_id],
      :player_ids => [params[:winner_id], params[:loser_id]]
    )
  end
end
