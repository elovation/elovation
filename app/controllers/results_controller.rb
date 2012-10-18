class ResultsController < ApplicationController
  before_filter :_find_game

  def create
    response = ResultService.create(@game, params[:result])

    if response.success?
      resolve_challenges_for_result(response.result)
      redirect_to game_path(@game)
    else
      @result = response.result
      render :new
    end
  end

  def resolve_challenges_for_result(result)
    Challenge.find_active_challenges_for_result(result).each do |c|
      c.result = result
      c.save
    end
  end

  def destroy
    result = @game.results.find_by_id(params[:id])

    response = ResultService.destroy(result)

    redirect_to :back
  end

  def new
    @result = Result.new
  end

  def _find_game
    @game = Game.find(params[:game_id])
  end
end
