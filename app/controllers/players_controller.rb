class PlayersController < ApplicationController
  before_action :set_player, only: [:edit, :destroy, :show, :update]

  def create
    @player = Player.new(player_params)

    if @player.save
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def destroy
    @player.destroy if @player.results.empty?
    redirect_to dashboard_path
  end

  def edit
  end

  def new
    @player = Player.new
  end

  def show
  end

  def update
    if @player.update_attributes(player_params)
      redirect_to player_path(@player)
    else
      render :edit
    end
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :email)
  end
end
