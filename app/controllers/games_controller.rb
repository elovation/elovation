class GamesController < ApplicationController
  before_action :set_game, only: [:destroy, :edit, :show, :update]

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
    redirect_to dashboard_path
  end

  def edit
  end

  def new
    @game = Game.new min_number_of_players_per_team: 1,
                     rating_type: "trueskill",
                     min_number_of_teams: 2,
                     allow_ties: true
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

    @chart_data = players.map do |player|
      {:name => player.name, :data => player_to_days[player.name].to_a}
    end

    respond_to do |format|
      format.html
      format.json do
        render json: @game
      end
    end
  end

  def update
    if @game.update_attributes(games_params)
      redirect_to game_path(@game)
    else
      render :edit
    end
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
