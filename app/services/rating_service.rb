class RatingService
  def self.update(game, winner, loser)
    winner_rating = winner.ratings.create(:game => game, :value => Rating::DefaultValue)
    loser_rating = loser.ratings.create(:game => game, :value => Rating::DefaultValue)

    winner_elo = winner_rating.to_elo
    loser_elo = loser_rating.to_elo

    winner_elo.wins_from(loser_elo)

    winner_rating.update_attributes!(:value => winner_elo.rating)
    loser_rating.update_attributes!(:value => loser_elo.rating)
  end
end
