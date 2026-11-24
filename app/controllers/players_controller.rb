class PlayersController < ApplicationController
  before_action :set_player, only: [:edit, :destroy, :show, :update]

  def index
    @players = Player.order(id: :desc)
  end

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to players_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @player.update(player_params)
      redirect_to player_path(@player)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Deleting a player with results would cascade-delete their opponents'
    # results without recalculating ratings, so only allow it with no results.
    @player.destroy if @player.results.empty?

    redirect_to players_path, status: :see_other
  end

  def edit
  end

  def new
    @player = Player.new
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :email)
  end
end
