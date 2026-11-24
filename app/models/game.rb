class Game < ApplicationRecord
  default_scope { order("updated_at DESC") }

  has_many :ratings, dependent: :destroy
  has_many :results, dependent: :destroy

  validates :name, presence: true
  validates :rating_type, inclusion: { in: ->(_game) { RatingSystems.keys }, message: "must be a valid rating type" }
  validate { rating_system&.validate_game(self) }

  validates :min_number_of_teams, numericality: { only_integer: true, greater_than_or_equal_to: 2 }
  validates :max_number_of_teams, numericality: { only_integer: true, allow_nil: true }
  validate do |game|
    if game.min_number_of_teams && game.max_number_of_teams && game.min_number_of_teams > game.max_number_of_teams
      game.errors.add(:max_number_of_teams, "cannot be less than the minimum")
    end
  end

  validates :min_number_of_players_per_team, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :max_number_of_players_per_team, numericality: { only_integer: true, allow_nil: true }
  validate do |game|
    if game.min_number_of_players_per_team && game.max_number_of_players_per_team && game.min_number_of_players_per_team > game.max_number_of_players_per_team
      game.errors.add(:max_number_of_teams, "cannot be less than the minimum")
    end
  end

  validate do |game|
    if game.rating_type_was && game.rating_type_changed?
      game.errors.add(:rating_type, "cannot be changed")
    end
  end

  validates :allow_ties, inclusion: { in: [true, false], message: "must be selected" }

  def all_ratings
    ratings.order(value: :desc)
  end

  def as_json(options = {})
    {
      name: name,
      ratings: top_ratings.map(&:as_json),
      results: recent_results.map(&:as_json)
    }
  end

  def players
    ratings.map(&:player)
  end

  def recent_results
    results.order("created_at DESC").limit(20)
  end

  def top_ratings
    ratings.order("value DESC").limit(5)
  end

  def rating_system
    RatingSystems.fetch(rating_type)
  end

  # Rates one result. `teams` are the result's ranked Teams.
  def rate!(teams)
    ratings = {}
    standings = teams.map do |team|
      team_ratings = team.players.to_h do |player|
        rating = ratings[player.id] = player.ratings.find_or_create(self)
        [player.id, rating.state]
      end
      RatingSystems::Standing.new(rank: team.rank, ratings: team_ratings)
    end

    rating_system.rate(standings).each do |player_id, state|
      ratings.fetch(player_id).record!(state)
    end
  end

  def recalculate_ratings!
    RatingHistoryEvent.joins(:rating).where(ratings: {game_id: self.id}).destroy_all
    Rating.where(game_id: self.id).destroy_all

    results.order("id ASC").all.each do |result|
      rate!(result.teams.order("rank ASC"))
    end
  end
end
