class PlayersController < ApplicationController
  before_filter :_find_player, :only => [:edit, :show, :update]

  def create
    @player = Player.new(params[:player])

    if @player.save
      redirect_to player_path(@player)
    else
      render :new
    end
  end

  def edit
  end

  def new
    @player = Player.new
  end

  def show
  end

  def update
    if @player.update_attributes(params[:player])
      redirect_to player_path(@player)
    else
      render :edit
    end
  end

  def _find_player
    @player = Player.find(params[:id])
  end
end
