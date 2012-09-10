class ResultsController < ApplicationController
  before_filter :_find_game

  def create
    response = ResultService.create(@game, params[:result])

    if response.success?
      resolve_challenge_for_result(response.result)
      redirect_to game_path(@game)
    else
      @result = response.result
      render :new
    end
  end

  def resolve_challenge_for_result(result)
    challenge = Challenge.find_active_challenge_for_game_and_players(result.game, result.winner, result.loser)
    if challenge
      challenge.result = result
      challenge.save
    end
  end

  def destroy
    result = @game.results.find_by_id(params[:id])

    response = ResultService.destroy(result)

    redirect_to game_path(@game)
  end

  def new
    @result = Result.new
  end

  def _find_game
    @game = Game.find(params[:game_id])
  end
end
