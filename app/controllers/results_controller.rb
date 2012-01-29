class ResultsController < ApplicationController
  before_filter :_find_game

  def create
    response = ResultService.create(@game, params[:result])

    if response.success?
      redirect_to game_path(@game)
    else
      @result = response.result
      render :new
    end
  end

  def new
    @result = Result.new
  end

  def _find_game
    @game = Game.find(params[:game_id])
  end
end
