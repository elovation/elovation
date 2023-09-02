class DashboardController < ApplicationController
  def index
    @games = Game.all
  end
end
