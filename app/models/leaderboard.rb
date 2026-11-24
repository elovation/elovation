# frozen_string_literal: true

# A game's ratings and their history. Ratings are derived from the game's
# results by its rating system, and this is the only module that writes them.
#
#   leaderboard = game.leaderboard
#   leaderboard.record(result)    # rate a newly saved result
#   leaderboard.retract(result)   # remove the latest result and undo its ratings
#   leaderboard.rebuild           # recompute every rating from the results
#   leaderboard.preview(system)   # what ratings would be under any rating system (no writes)
#   leaderboard.history_by_day    # each player's score at the end of every day played
#
# Recording a result is one step of a rebuild, so a rebuild always reproduces
# the ratings that were recorded live.
class Leaderboard
  Entry = Data.define(:player_id, :score, :state)

  attr_reader :game

  def initialize(game)
    @game = game
  end

  # Rates a saved result from its players' current ratings, and appends the
  # new states to their history at the time of the result.
  def record(result)
    Rating.transaction do
      ratings = result.players.to_h { |player| [player.id, player.ratings.find_or_create(game)] }
      replay = RatingSystems::Replay.new(game.rating_system, ratings.transform_values(&:state))

      replay.play(placings(result)).each do |player_id, state|
        rating = ratings.fetch(player_id)
        rating.update!(state: state)
        rating.history_events.create!(value: rating.value, state: state, created_at: result.created_at)
      end
    end
  end

  # Removes a result and restores its players' previous ratings. Only a result
  # that is the latest for every one of its players can be retracted. Returns
  # whether the result was retracted.
  def retract(result) # rubocop:disable Naming/PredicateMethod
    return false unless result.most_recent?

    Rating.transaction do
      result.players.each { |player| rewind(game.ratings.find_by!(player: player)) }
      result.destroy!
    end
    true
  end

  # Discards every rating and recomputes them from the game's results in order.
  def rebuild
    Rating.transaction do
      game.ratings.destroy_all
      game.results.reorder(:id).each { |result| record(result) }
    end
  end

  # Ratings the game's results would produce under `system`, best first,
  # without saving anything. Raises ArgumentError if `system` can't rate this
  # game's format.
  def preview(system = game.rating_system)
    unless system.supported_format.supports?(game)
      raise ArgumentError,
            "#{system.name} can only be used with #{system.supported_format.summary}"
    end

    replay = RatingSystems::Replay.new(system)
    game.results.reorder(:id).includes(teams: :players).each { |result| replay.play(placings(result)) }

    replay.states
          .map { |player_id, state| Entry.new(player_id: player_id, score: system.score(state), state: state) }
          .sort_by { |entry| -entry.score }
  end

  # Each rated player's score at the end of every day the game was played,
  # best player first, as [player, [[day, score], ...]]. A player's score is
  # nil on days before their first result.
  def history_by_day
    ratings = game.ratings.includes(:player, :history_events).order(value: :desc, id: :asc)
    scores = ratings.to_h { |rating| [rating.player, end_of_day_scores(rating)] }
    days = scores.values.flat_map(&:keys).uniq.sort

    scores.map do |player, by_day|
      score = nil
      [player, days.map { |day| [day, score = by_day.fetch(day, score)] }]
    end
  end

  private

  # Teams in the order they were entered, so recording and rebuilding always
  # give a rating system the same input.
  def placings(result)
    result.teams.sort_by(&:id).map do |team|
      RatingSystems::Placing.new(rank: team.rank, participants: team.players.map(&:id))
    end
  end

  def end_of_day_scores(rating)
    rating.history_events
          .sort_by { |event| [event.created_at, event.id] }
          .to_h { |event| [event.created_at.to_date.to_s, event.value] }
  end

  def rewind(rating)
    current, previous = rating.history_events.first(2)

    if previous
      rating.update!(state: previous.state)
      current.destroy!
    else
      rating.destroy!
    end
  end
end
