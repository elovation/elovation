class PlayerGamesController < ApplicationController
  def show
    @player = Player.find(params[:player_id])
    @game = Game.find(params[:id])
    @chart_data = @game
                      .ratings
                      .flat_map(&:history_events)
                      .select {|e| e.rating_id == @player.id }
                      .map { |event| [event.created_at, event.value] }
  end
end
