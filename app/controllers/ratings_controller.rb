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

  private

  def getRatings(game)
    {
      game_name: game.name,
      ratings: game.all_ratings.map do |rating|
        {
          player: getPlayerToJSONise(rating.player),
          value: rating.value,
          wins: rating.wins,
          losses: rating.losses
        }
      end
    }
  end

  private

  def getPlayerToJSONise(player)
    result = {
      name: player.name,
      gravatar_url: view_context.gravatar_url(player, size: 24)
    }
    if (flair = player.flair)
      result[:flair] = {
        name: flair.name,
        avatar_thumb: getAvatarThumbnailURL(flair)
      }
    end
    return result
  end

  def getAvatarThumbnailURL(flair)
    "#{request.protocol}#{request.host_with_port}#{flair.avatar.url(:thumb)}"
  end
end
