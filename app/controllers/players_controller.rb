class PlayersController < ApplicationController
  before_filter :_find_player, :only => [:destroy, :edit, :update]

  def create
    @player = Player.new(params[:player])

    if @player.save
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def destroy
    @player.destroy

    redirect_to dashboard_path
  end

  def edit
  end

  def new
    @player = Player.new
  end

  def update
    if @player.update_attributes(params[:player])
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  def _find_player
    @player = Player.find(params[:id])
  end
end
