class GamesController < ApplicationController
  before_filter :_find_game, :only => [:destroy, :edit, :update]

  def create
    @game = Game.new(params[:game])

    if @game.save
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def destroy
    @game.destroy

    redirect_to dashboard_path
  end

  def edit
  end

  def new
    @game = Game.new
  end

  def update
    if @game.update_attributes(params[:game])
      redirect_to dashboard_path
    else
      render :edit
    end
  end

  def _find_game
    @game = Game.find(params[:id])
  end
end
