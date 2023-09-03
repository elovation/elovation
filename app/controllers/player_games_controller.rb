class PlayerGamesController < ApplicationController
  def show
    @player = Player.find(params[:player_id])
    @game = Game.find(params[:id])
    @chart_data = @game.ratings
                      .where(player_id: @player.id)
                      .flat_map(&:history_events)
                      .map { |event| [event.created_at, event.value] }
  end
end
