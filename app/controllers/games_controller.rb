class GamesController < ApplicationController
  def new
    @game = Game.new
  end

  def create
    @game = Game.new(params[:game])

    if @game.save
      redirect_to dashboard_path
    else
      render :new
    end
  end
end
