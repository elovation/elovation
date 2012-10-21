class PlayerGamesController < ApplicationController
  def show
    @player = Player.find(params[:player_id])
    @game = Game.find(params[:id])
    @wins_and_losses = @game.wins_and_losses_against(@player)
    @deletable_results = Result.find_deletable_for(@game)
  end
end
