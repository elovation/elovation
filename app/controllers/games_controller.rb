class GamesController < ApplicationController
  def new
    @game = Game.new
  end
end
