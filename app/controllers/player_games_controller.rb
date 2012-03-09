class PlayerGamesController < ApplicationController
  def show
    @player = Player.find(params[:player_id])
    @game = Game.find(params[:id])
  end
end
