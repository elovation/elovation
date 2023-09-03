class GamesController < ApplicationController
  before_action :set_game, only: [:show]

  def index
    @games = Game.order(id: :desc)
  end

  def create
    @game = Game.new(games_params)

    if @game.save
      redirect_to game_path(@game)
    else
      render :new
    end
  end

  def new
    @game = Game.new min_number_of_players_per_team: 1,
                     rating_type: "trueskill",
                     min_number_of_teams: 2,
                     allow_ties: true,
                     max_number_of_players_per_team: 2,
                     max_number_of_teams: 2
  end

  private

  def set_game
    @game = Game.find(params[:id])
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
