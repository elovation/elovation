class GamesController < ApplicationController
  include ParamsCleaner

  allowed_params :game => [:name, :description]

  before_filter :_find_game, :only => [:destroy, :edit, :show, :update]

  def create
    @game = Game.new(clean_params[:game])

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
    @game = Game.new
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render :json => @game
      end
    end
  end

  def update
    if @game.update_attributes(clean_params[:game])
      redirect_to game_path(@game)
    else
      render :edit
    end
  end

  def _find_game
    @game = Game.find(params[:id])
  end
end
