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

  def by_days
    @game = Game.find(params[:game_id])

    by_days = @game.all_ratings.each_with_index.map do |rating, i|
      from = 4.weeks.ago.midnight
      ratings_by_day = rating.history_events.where(created_at: from..Time.now).to_a.group_by_day(&:created_at)
      each_days_last_rating = ratings_by_day.map do |day, ratings|
        # A days last rating is actually the first in the array, because it's orderd by :created_at desc
        [day, ratings.first.value] unless ratings.empty?
      end.compact
      rating_before = rating.history_events.where("created_at < ?", from).first
      # Subtract a day from the first date to make it appear before the 1st actual
      # point on the graph
      each_days_last_rating.unshift([from - 1.day, rating_before.value]) unless rating_before.nil?
      {
        name: rating.player.name,
        data: each_days_last_rating,
        # Only the top 3 are initially visible
        visible: i < 3
      }
    end

    render json: by_days
  end

  private

  def getRatings(game)
    {
      game_name: game.name,
      ratings: game.all_ratings.select(&:active?).map do |rating|
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
