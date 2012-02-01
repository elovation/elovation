class RatingService
  def self.update(game, winner, loser)
    winner_rating = _find_or_create_rating(game, winner)
    loser_rating = _find_or_create_rating(game, loser)

    winner_elo = winner_rating.to_elo
    loser_elo = loser_rating.to_elo

    winner_elo.wins_from(loser_elo)

    winner_rating.update_attributes!(
      :value => winner_elo.rating,
      :pro => winner_elo.pro?
    )
    loser_rating.update_attributes!(
      :value => loser_elo.rating,
      :pro => winner_elo.pro?
    )
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
end
