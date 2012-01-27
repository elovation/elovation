class PlayersController < ApplicationController
  def new
    @player = Player.new
  end

  def create
    @player = Player.new(params[:player])

    if @player.save
      redirect_to dashboard_path
    else
      render :new
    end
  end
end
