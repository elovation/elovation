class PlayersController < ApplicationController
  include ParamsCleaner

  allowed_params :player => [:name, :email]

  before_filter :_find_player, :only => [:edit, :destroy, :show, :update]

  def create
    @player = Player.new(clean_params[:player])

    if @player.save
      redirect_to player_path(@player)
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
    if @player.update_attributes(clean_params[:player])
      redirect_to player_path(@player)
    else
      render :edit
    end
  end

  def _find_player
    @player = Player.find(params[:id])
  end
end
