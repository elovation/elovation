require "rails_helper"

RSpec.describe Game, type: :model do
  describe "name" do
    it "has a name" do
      game = FactoryBot.create(:game, name: "Go")

      expect(game.name).to eq("Go")
    end
  end

  describe "players" do
    it "returns players who have a rating for the game" do
      game = FactoryBot.create(:game)
      player1 = FactoryBot.create(:player)
      player2 = FactoryBot.create(:player)
      FactoryBot.create(:rating, game: game, player: player1)
      FactoryBot.create(:rating, game: game, player: player2)
      expect(game.players.sort_by(&:id)).to eq([player1, player2])
    end
  end

  describe "recent results" do
    it "returns 10 of the games results" do
      game = FactoryBot.create(:game)
      21.times { FactoryBot.create(:result, game: game) }

      expect(game.recent_results.size).to eq(20)
    end

    it "returns the 20 most recently created results" do
      newer_results = nil
      game = FactoryBot.create(:game)

      travel_to(3.days.ago) do
        5.times.map { FactoryBot.create(:result, game: game) }
      end

      travel_to(1.day.ago) do
        newer_results = 20.times.map { FactoryBot.create(:result, game: game) }
      end

      expect(game.recent_results.sort).to eq(newer_results.sort)
    end

    it "orders results by created_at, descending" do
      game = FactoryBot.create(:game)
      old = new = nil

      travel_to(2.days.ago) do
        old = FactoryBot.create(:result, game: game)
      end

      travel_to(1.days.ago) do
        new = FactoryBot.create(:result, game: game)
      end

      expect(game.recent_results).to eq([new, old])
    end

    it "orders games by updated_at, descending" do
      game1 = FactoryBot.create(:game)
      game2 = FactoryBot.create(:game)

      expect(Game.all).to eq([game2, game1])
    end
  end

  describe "top_ratings" do
    it "returns 5 ratings associated with the game" do
      game = FactoryBot.create(:game)
      10.times { FactoryBot.create(:rating, game: game) }

      expect(game.top_ratings.count).to eq(5)
    end

    it "orders ratings by value, descending" do
      game = FactoryBot.create(:game)
      rating2 = FactoryBot.create(:rating, game: game, value: 2)
      rating3 = FactoryBot.create(:rating, game: game, value: 3)
      rating1 = FactoryBot.create(:rating, game: game, value: 1)

      expect(game.top_ratings).to eq([rating3, rating2, rating1])
    end
  end

  describe "all_ratings" do
    it "orders all ratings by value, descending" do
      game = FactoryBot.create(:game)
      rating2 = FactoryBot.create(:rating, game: game, value: 2)
      rating3 = FactoryBot.create(:rating, game: game, value: 3)
      rating1 = FactoryBot.create(:rating, game: game, value: 1)
      rating4 = FactoryBot.create(:rating, game: game, value: 4)
      rating5 = FactoryBot.create(:rating, game: game, value: 5)
      rating6 = FactoryBot.create(:rating, game: game, value: 6)

      expect(game.all_ratings).to eq([rating6, rating5, rating4, rating3, rating2, rating1])
    end

    # Regression: tied ratings came back in whatever order Postgres stored
    # them, which changes when a row is updated.
    it "orders tied ratings consistently, earliest rating first" do
      game = FactoryBot.create(:game)
      first = FactoryBot.create(:rating, game: game, value: 5)
      second = FactoryBot.create(:rating, game: game, value: 5)
      first.update_column(:value, 5)

      expect(game.all_ratings).to eq([first, second])
      expect(game.top_ratings).to eq([first, second])
    end
  end

  describe "validations" do
    context "name" do
      it "must be present" do
        game = FactoryBot.build(:game, name: nil)

        expect(game).not_to be_valid
        expect(game.errors[:name]).to eq(["can't be blank"])
      end
    end

    context "min_number_of_teams" do
      it "can be 2" do
        game = FactoryBot.build(:game, min_number_of_teams: 2)

        expect(game).to be_valid
      end

      it "can be greater than 2" do
        game = FactoryBot.build(:game, min_number_of_teams: 3, max_number_of_teams: 3)

        expect(game).to be_valid
      end

      it "cannot be less than 2" do
        game = FactoryBot.build(:game, min_number_of_teams: 1)

        expect(game).not_to be_valid
        expect(game.errors[:min_number_of_teams]).to eq(["must be greater than or equal to 2"])
      end

      it "cannot be nil" do
        game = FactoryBot.build(:game, min_number_of_teams: nil)

        expect(game).not_to be_valid
        expect(game.errors[:min_number_of_teams]).to eq(["is not a number"])
      end
    end

    context "max_number_of_teams" do
      it "can be equal to min number of teams" do
        game = FactoryBot.build(:game, min_number_of_teams: 2, max_number_of_teams: 2)

        expect(game).to be_valid
      end

      it "can be greater than the min number of teams" do
        game = FactoryBot.build(:game, min_number_of_teams: 2, max_number_of_teams: 3)

        expect(game).to be_valid
      end

      it "can be nil" do
        game = FactoryBot.build(:game, min_number_of_teams: 2, max_number_of_teams: nil)

        expect(game).to be_valid
      end

      it "cannot be less than the min number of teams" do
        game = FactoryBot.build(:game, min_number_of_teams: 2, max_number_of_teams: 1)

        expect(game).not_to be_valid
        expect(game.errors[:max_number_of_teams]).to eq(["cannot be less than the minimum"])
      end
    end

    context "min_number_of_players_per_team" do
      it "can be 1" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: 1)

        expect(game).to be_valid
      end

      it "can be greater than 1" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 2)

        expect(game).to be_valid
      end

      it "cannot be less than 1" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: 0)

        expect(game).not_to be_valid
        expect(game.errors[:min_number_of_players_per_team]).to eq(["must be greater than or equal to 1"])
      end

      it "cannot be nil" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: nil)

        expect(game).not_to be_valid
        expect(game.errors[:min_number_of_players_per_team]).to eq(["is not a number"])
      end
    end

    context "max_number_of_players_per_team" do
      it "can be equal to the min number of players per team" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 2)

        expect(game).to be_valid
      end

      it "can be greater than the min number of players per team" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 3)

        expect(game).to be_valid
      end

      it "can be nil" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: nil)

        expect(game).to be_valid
      end

      # Regression: the error was added to max_number_of_teams, so the form
      # showed it against the wrong field.
      it "cannot be less than the min number of players per team" do
        game = FactoryBot.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 1)

        expect(game).not_to be_valid
        expect(game.errors[:max_number_of_players_per_team]).to eq(["cannot be less than the minimum"])
        expect(game.errors[:max_number_of_teams]).to be_empty
      end
    end

    context "allow_ties" do
      it "can be true" do
        game = FactoryBot.build(:game, allow_ties: true)

        expect(game).to be_valid
      end

      it "can be false" do
        game = FactoryBot.build(:game, allow_ties: false)

        expect(game).to be_valid
      end

      it "cannot be nil" do
        game = FactoryBot.build(:game, allow_ties: nil)

        expect(game).not_to be_valid
        expect(game.errors[:allow_ties]).to eq(["must be selected"])
      end
    end

    context "rating_type" do
      it "must be present" do
        game = FactoryBot.build(:game, rating_type: nil)

        expect(game).not_to be_valid
        expect(game.errors[:rating_type]).to eq(["must be a valid rating type"])
      end

      it "can be elo" do
        game = FactoryBot.build(:game, rating_type: "elo")

        expect(game).to be_valid
      end

      it "can be trueskill" do
        game = FactoryBot.build(:game, rating_type: "trueskill")

        expect(game).to be_valid
      end

      it "cannot be anything else" do
        game = FactoryBot.build(:game, rating_type: "foo")

        expect(game).not_to be_valid
        expect(game.errors[:rating_type]).to eq(["must be a valid rating type"])
      end

      it "cannot be changed" do
        game = FactoryBot.build(:game, rating_type: "elo")
        game.save!

        game.rating_type = "trueskill"
        expect(game).not_to be_valid
        expect(game.errors[:rating_type]).to eq(["cannot be changed"])
      end
    end

    describe "with elo rating type" do
      it "does not allow more than 2 teams" do
        game = FactoryBot.build(:game, rating_type: "elo", max_number_of_teams: 3)
        expect(game).not_to be_valid
        expect(game.errors[:rating_type]).to eq(["Elo can only be used with 1v1 games"])
      end

      it "does not allow more than 1 player per team" do
        game = FactoryBot.build(:game, rating_type: "elo", max_number_of_players_per_team: 2)
        expect(game).not_to be_valid
        expect(game.errors[:rating_type]).to eq(["Elo can only be used with 1v1 games"])
      end
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      game = FactoryBot.create(:game)
      rating = FactoryBot.create(:rating, game: game)
      result = FactoryBot.create(:result, game: game)

      game.destroy

      expect(Rating.find_by_id(rating.id)).to be_nil
      expect(Result.find_by_id(result.id)).to be_nil
    end
  end
end
