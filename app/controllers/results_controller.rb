# frozen_string_literal: true

class ResultsController < ApplicationController
  before_action :set_game

  def create
    response = ResultService.create(@game, params[:result])

    if response.success?
      redirect_to game_path(@game)
    else
      @result = response.result
      prepare_form(params.dig(:result, :teams))
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    result = @game.results.find_by_id(params[:id])

    ResultService.destroy(result)

    redirect_to request.referer || game_path(@game), status: :see_other
  end

  def new
    @result = Result.new
    prepare_form
  end

  private

  # The form has a slot per team the game allows, prefilled with what was
  # submitted when it's shown again.
  def prepare_form(submitted_teams = nil)
    @team_count = @game.max_number_of_teams || 20
    @team_game = @game.max_number_of_players_per_team != 1
    @submitted_teams = submitted_teams || {}
  end

  def set_game
    @game = Game.find(params[:game_id])
  end
end
