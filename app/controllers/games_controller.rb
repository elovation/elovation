class GamesController < ApplicationController
  before_action :set_game, only: [:edit, :update, :show, :destroy]

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

  def destroy
    @game.destroy if @game.results.empty?
    redirect_to root_path
  end

  def edit
  end

  def new
    @game = Game.new min_number_of_players_per_team: 1,
                     rating_type: "trueskill",
                     min_number_of_teams: 2,
                     allow_ties: true,
                     max_number_of_players_per_team: 2,
                     max_number_of_teams: 2
  end

  def show
    players = Player.all.includes(ratings: :history_events).where(ratings: { game: @game })

    player_to_days = Hash.new
    every_day = Set.new
    players.each do |player|
      day_to_event = Hash.new
      RatingHistoryEvent.events(player, @game).each do |event|
        day_to_event[event.created_at.to_date.to_s] = event.value
        every_day.add(event.created_at.to_date.to_s)
      end
      player_to_days[player.name] = day_to_event
    end

    players.each do |player|
      last_rating = nil
      every_day.to_a.sort.each_with_index do |day, i|
        last_rating = player_to_days[player.name].fetch(day, last_rating)
        player_to_days[player.name][day] = last_rating
      end
    end

    # sort players by final rating for display in chart
    sorted_players = players.sort { |a, b| b.ratings.where(game: @game).first.value <=> a.ratings.where(game: @game).first.value }

    @chart_data = sorted_players.map do |player|
      {:name => player.name, :data => player_to_days[player.name].to_a}
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
      redirect_to game_path(@game), status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_update_params
    if params[:rating_type] == 'elo'
      params.require(:game).permit(:name,
        :allow_ties)
    else
      params.require(:game).permit(:name,
        :max_number_of_teams,
        :max_number_of_players_per_team,
        :allow_ties)
    end
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
