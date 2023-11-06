class RatingsController < ApplicationController
  def index
    @game = Game.find(params[:game_id])
  end
end
