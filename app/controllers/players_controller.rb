class PlayersController < ApplicationController
  def new
    @player = Player.new
  end
end
