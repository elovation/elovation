class RatingService
  def self.update(game, winner, loser)
    winner_rating = _find_or_create_rating(game, winner)
    loser_rating = _find_or_create_rating(game, loser)

    winner_elo = winner_rating.to_elo
    loser_elo = loser_rating.to_elo

    winner_elo.wins_from(loser_elo)

    _update_rating_from_elo(winner_rating, winner_elo)
    _update_rating_from_elo(loser_rating, loser_elo)
  end

  def self._find_or_create_rating(game, player)
    if player.ratings.where(:game_id => game.id).any?
      player.ratings.where(:game_id => game.id).first
    else
      player.ratings.create(
        :game => game,
        :value => Rating::DefaultValue,
        :pro => false
      )
    end
  end

  def self._update_rating_from_elo(rating, elo)
    Rating.transaction do
      rating.update_attributes!(:value => elo.rating, :pro => elo.pro?)
      rating.history_events.create!(:value => elo.rating)
    end
  end
end
