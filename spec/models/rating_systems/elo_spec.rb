require "rails_helper"

RSpec.describe RatingSystems::Elo do
  it_behaves_like "a rating system"

  def state(rating: 1000, games_played: 0, pro: false)
    { "rating" => rating, "games_played" => games_played, "pro" => pro }
  end

  def play(first, second, tie: false)
    described_class.rate([
      RatingSystems::Standing.new(rank: 1, ratings: { first: first }),
      RatingSystems::Standing.new(rank: tie ? 1 : 2, ratings: { second: second })
    ]).values_at(:first, :second)
  end

  describe "rate" do
    it "moves equal newcomers by half the starter K-factor of 25, truncated" do
      winner, loser = play(state, state)

      expect(winner["rating"]).to eq(1012)
      expect(loser["rating"]).to eq(987)
    end

    it "leaves equal players unchanged after a draw" do
      first, second = play(state, state, tie: true)

      expect([first["rating"], second["rating"]]).to eq([1000, 1000])
    end

    it "uses a K-factor of 15 from 30 games played" do
      winner, loser = play(state(games_played: 30), state(games_played: 30))

      expect([winner["rating"], loser["rating"]]).to eq([1007, 992])
    end

    it "uses a K-factor of 10 for pros, even before 30 games" do
      winner, loser = play(state(pro: true), state(pro: true))

      expect([winner["rating"], loser["rating"]]).to eq([1005, 995])
    end

    it "uses a K-factor of 10 at a rating of 2400 or more, and marks the player as a pro" do
      winner, = play(state(rating: 2400), state(rating: 2400))

      expect(winner).to eq(state(rating: 2405, games_played: 1, pro: true))
    end

    it "keeps the pro flag after the rating falls below 2400" do
      _, loser = play(state(rating: 2300), state(rating: 2300, pro: true))

      expect(loser["rating"]).to be < 2400
      expect(loser["pro"]).to be(true)
    end

    it "counts games played" do
      winner, loser = play(state(games_played: 4), state(games_played: 9))

      expect([winner["games_played"], loser["games_played"]]).to eq([5, 10])
    end
  end

  describe "score" do
    it "is the rating" do
      expect(described_class.score(state(rating: 1234))).to eq(1234)
    end
  end

  describe "validate_game" do
    it "accepts one-on-one games" do
      game = FactoryBot.build(:elo_game)

      expect(game).to be_valid
    end

    it "rejects team games" do
      game = FactoryBot.build(:elo_game, max_number_of_players_per_team: 2)

      expect(game).not_to be_valid
      expect(game.errors[:rating_type]).to eq(["Elo can only be used with 1v1 games"])
    end
  end
end
