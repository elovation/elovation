class DashboardController < ApplicationController
  def index
    @players = Player.all.sort_by(&:name)
    @games = Game.all
  end
end
