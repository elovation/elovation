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
      redirect_to players_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
  
    respond_to do |f|
      f.turbo_stream { render turbo_stream: turbo_stream.remove(@player) }
      f.html { redirect_to players_path }
    end
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
