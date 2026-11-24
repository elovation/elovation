# frozen_string_literal: true

class ResultsController < ApplicationController
  before_action :set_game

  def create
    response = ResultService.create(@game, params[:result])

    if response.success?
      redirect_to game_path(@game)
    else
      @result = response.result
      render :new
    end
  end

  def destroy
    result = @game.results.find_by_id(params[:id])

    ResultService.destroy(result)

    redirect_to request.referer || game_path(@game), status: :see_other
  end

  def new
    @result = Result.new
    (@game.max_number_of_teams || 20).times { |i| @result.teams.build rank: i }
    @team_game = @game.max_number_of_players_per_team != 1
  end

  private

  def set_game
    @game = Game.find(params[:game_id])
  end
end
