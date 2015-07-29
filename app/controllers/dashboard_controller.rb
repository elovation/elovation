class DashboardController < ApplicationController
  def show
    @players = Player.all.sort_by(&:name)
    @games = Game.all
  end
end
