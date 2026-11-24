# frozen_string_literal: true

class Game < ApplicationRecord
  default_scope { order('updated_at DESC') }

  has_many :ratings, dependent: :destroy
  has_many :results, dependent: :destroy

  validates :name, presence: true
  validates :theme, inclusion: { in: Theme.keys }, allow_blank: true
  validates :rating_type, inclusion: { in: ->(_game) { RatingSystems.keys }, message: 'must be a valid rating type' }
  validate do
    if rating_system && !rating_system.supported_format.supports?(self)
      errors.add(:rating_type, "#{rating_system.name} can only be used with #{rating_system.supported_format.summary}")
    end
  end

  validates :min_number_of_teams, numericality: { only_integer: true, greater_than_or_equal_to: 2 }
  validates :max_number_of_teams, numericality: { only_integer: true, allow_nil: true }
  validate { validate_not_below(:max_number_of_teams, :min_number_of_teams) }

  validates :min_number_of_players_per_team, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :max_number_of_players_per_team, numericality: { only_integer: true, allow_nil: true }
  validate { validate_not_below(:max_number_of_players_per_team, :min_number_of_players_per_team) }

  validate do |game|
    game.errors.add(:rating_type, 'cannot be changed') if game.rating_type_was && game.rating_type_changed?
  end

  validates :allow_ties, inclusion: { in: [true, false], message: 'must be selected' }

  def all_ratings
    ratings.order(value: :desc, id: :asc)
  end

  def as_json(_options = {})
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
    results.order('created_at DESC').limit(20)
  end

  def top_ratings
    ratings.order(value: :desc, id: :asc).limit(5)
  end

  def rating_system
    RatingSystems.fetch(rating_type)
  end

  # The theme its pages use: its own, or the site's.
  def look
    theme.presence || Theme.site
  end

  # This game's ratings: record, retract, rebuild and preview them.
  def leaderboard
    Leaderboard.new(self)
  end

  private

  def validate_not_below(max_attribute, min_attribute)
    max = public_send(max_attribute)
    min = public_send(min_attribute)
    errors.add(max_attribute, 'cannot be less than the minimum') if max && min && max < min
  end
end
