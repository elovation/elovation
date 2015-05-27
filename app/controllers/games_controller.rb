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
    every_date = @game.ratings.flat_map(&:history_events).map { |e| e.created_at.to_date.to_s }.sort.uniq

    @chart_data = Player.all.map do |player|
      player_events = @game.ratings.where(player_id: player.id).flat_map(&:history_events)
      last_value = nil

      if player_events.empty?
        nil
      else
        data = every_date.map do |date|
          last_value = player_events.select {|e| e.created_at.to_date.to_s == date }.last rescue last_value

          if last_value
            [date, last_value.value]
          else
            nil
          end
        end

        {name: player.name, data: data.compact}
      end
    end.compact

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
