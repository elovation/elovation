# frozen_string_literal: true

class GamesController < ApplicationController
  before_action :set_game, only: %i[edit update show destroy]

  def index
    @games = Game.order(id: :desc)
  end

  def create
    @game = Game.new(games_params)

    if @game.save
      redirect_to game_path(@game)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @game.destroy if @game.results.empty?
    redirect_to root_path
  end

  def edit; end

  def new
    @game = Game.new min_number_of_players_per_team: 1,
                     rating_type: 'trueskill',
                     min_number_of_teams: 2,
                     allow_ties: true,
                     max_number_of_players_per_team: 2,
                     max_number_of_teams: 2
  end

  def show
    @chart_data = @game.leaderboard.history_by_day.map do |player, scores|
      { name: player.name, data: scores }
    end

    @ratings = @game.all_ratings

    respond_to do |format|
      format.html
      format.json do
        render json: @game
      end
    end
  end

  def update
    if @game.update(game_update_params)
      redirect_to game_path(@game)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  # Limits the rating system fixes (e.g. Elo's 1v1) can't be edited.
  def game_update_params
    format = @game.rating_system.supported_format
    permitted = %i[name allow_ties]
    permitted << :max_number_of_teams unless format.fixed_teams
    permitted << :max_number_of_players_per_team unless format.fixed_players_per_team
    params.require(:game).permit(*permitted)
  end

  def games_params
    params.require(:game).permit(:name,
                                 :rating_type,
                                 :min_number_of_teams,
                                 :max_number_of_teams,
                                 :min_number_of_players_per_team,
                                 :max_number_of_players_per_team,
                                 :allow_ties)
  end
end
