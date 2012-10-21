class Rating < ActiveRecord::Base
  DefaultValue = 1000

  belongs_to :game
  belongs_to :player
  has_many :history_events, :class_name => "RatingHistoryEvent", :dependent => :destroy, :order => "created_at DESC"

  def self.active_rating_threshold
    4.weeks.ago
  end

  def active?
    if most_recent_result
      most_recent_result.created_at >= self.class.active_rating_threshold
    else
      false
    end
  end

  def as_json(option = {})
    {
      :player => player.as_json,
      :value => value
    }
  end

  def most_recent_result
    player.results.for_game(game).most_recent_first.first
  end

  def to_elo
    Elo::Player.new(
      :rating => value,
      :games_played => player.results.where(:game_id => game.id).count,
      :pro => pro?
    )
  end

  def rewind!
    if history_events.count == 1
      destroy
    else
      Rating.transaction do
        update_attributes!(:value => _previous_rating.value)
        _current_rating.destroy
      end
    end
  end

  def _current_rating
    history_events.first
  end

  def _previous_rating
    history_events.second
  end
end
