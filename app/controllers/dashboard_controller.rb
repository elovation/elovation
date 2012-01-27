class DashboardController < ApplicationController
  def show
    @players = Player.all
    @games = Game.all
  end
end
