class RatingsController < ApplicationController
  protect_from_forgery except: :index
  respond_to :html, :json, :js

  def index
    @game = Game.find(params[:game_id])

    respond_with do |format|
      format.json { render :json => getRatings(@game) }
      format.js   { render :json => getRatings(@game), :callback => params[:callback] }
    end
  end

  def getRatings(game)
    ratings = game.all_ratings.map do |rating|
      {
        player: {
          name: rating.player.name,
          gravatar_url: view_context.gravatar_url(rating.player, size: 24)
        },
        value: rating.value,
        wins: rating.player.results.for_game(rating.game).wins.size,
        losses: rating.player.results.for_game(rating.game).losses.size
      }
    end
    {
      game_name: game.name,
      ratings: ratings
    }
  end
end
