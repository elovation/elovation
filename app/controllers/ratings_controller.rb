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
        ratingToJSONise = {
          player: getPlayerToJSONise(rating.player),
          value: rating.value,
          wins_percentage: rating.wins_percentage,
          losses_percentage: rating.losses_percentage
        }
        unless rating.change_since_yesterday.nil?
          ratingToJSONise[:change_since_yesterday] = rating.change_since_yesterday
        end
        if rating.player.display_game_count
          ratingToJSONise[:wins] = rating.wins
          ratingToJSONise[:losses] = rating.losses
        end
        ratingToJSONise
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
