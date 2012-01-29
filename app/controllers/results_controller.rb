class ResultsController < ApplicationController
  before_filter :_find_game

  def create
    @result = ResultService.build_result(@game, params[:result])

    if @result.save
      redirect_to game_path(@game)
    end
  end

  def new
    @result = Result.new(
      :players => [Player.new, Player.new]
    )
  end

  def _find_game
    @game = Game.find(params[:game_id])
  end
end
