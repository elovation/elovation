class DashboardController < ApplicationController
  def show
    @players = Player.all.sort_by(&:name)
    @games = Game.active
  end
end
