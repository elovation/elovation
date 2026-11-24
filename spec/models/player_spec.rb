require "rails_helper"

RSpec.describe Player, type: :model do
  describe "as_json" do
    it "returns the json representation of the player" do
      player = FactoryBot.build(:player, name: "John Doe", email: "foo@example.com")

      expect(player.as_json).to eq({
        name: "John Doe",
        email: "foo@example.com"
      })
    end
  end
  describe "validations" do
    context "name" do
      it "is required" do
        player = FactoryBot.build(:player, name: nil)

        expect(player).not_to be_valid
        expect(player.errors[:name]).to eq(["can't be blank"])
      end

      it "must be unique" do
        FactoryBot.create(:player, name: "Drew")
        player = FactoryBot.build(:player, name: "Drew")

        expect(player).not_to be_valid
        expect(player.errors[:name]).to eq(["has already been taken"])
      end
    end

    context "email" do
      it "can be blank" do
        player = FactoryBot.build(:player, email: "")
        expect(player).to be_valid
      end

      it "must be a valid email format" do
        player = Player.new
        player.email = "invalid-email-address"
        expect(player).not_to be_valid
        expect(player.errors[:email]).to eq(["expected an @ character"])
        player.email = "valid@example.com"
        player.valid?
        expect(player.errors[:email]).to eq([])
      end
    end
  end

  describe "name" do
    it "has a name" do
      player = FactoryBot.create(:player, name: "Drew")

      expect(player.name).to eq("Drew")
    end
  end

  describe "recent_results" do
    it "returns 5 of the player's results" do
      game = FactoryBot.create(:game)
      player = FactoryBot.create(:player)

      10.times { FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)]) }

      expect(player.recent_results.size).to eq(5)
    end

    it "returns the 5 most recently created results" do
      newer_results = nil
      game = FactoryBot.create(:game)
      player = FactoryBot.create(:player)

      travel_to(3.days.ago) do
        5.times { FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)]) }
      end

      travel_to(1.day.ago) do
        newer_results = 5.times.map { FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)]) }
      end

      expect(player.recent_results.sort).to eq(newer_results.sort)
    end

    it "orders results by created_at, descending" do
      game = FactoryBot.create(:game)
      player = FactoryBot.create(:player)
      old = new = nil

      travel_to(2.days.ago) do
        old = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)])
      end

      travel_to(1.days.ago) do
        new = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)])
      end

      expect(player.recent_results).to eq([new, old])
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      player = FactoryBot.create(:player)
      rating = FactoryBot.create(:rating, player: player)
      result = FactoryBot.create(:result, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)])

      player.destroy

      expect(Rating.find_by_id(rating.id)).to be_nil
      expect(Result.find_by_id(result.id)).to be_nil
    end
  end

  describe "ratings" do
    describe "find_or_create" do
      it "returns the rating if it exists" do
        player = FactoryBot.create(:player)
        game = FactoryBot.create(:game)
        rating = FactoryBot.create(:rating, game: game, player: player)

        expect do
          found_rating = player.ratings.find_or_create(game)
          expect(found_rating).to eq(rating)
        end.to_not change { player.ratings.count }
      end

      it "creates a rating and returns it if it doesn't exist" do
        player = FactoryBot.create(:player)
        game = FactoryBot.create(:game)

        expect do
          expect(player.ratings.find_or_create(game)).not_to be_nil
        end.to change { player.ratings.count }.by(1)
      end
    end
  end


  describe "wins" do
    it "finds wins" do
      player1 = FactoryBot.create(:player)
      player1WinTeam = FactoryBot.create(:team, rank: 1, players: [player1])

      player2 = FactoryBot.create(:player)
      player2WinTeam = FactoryBot.create(:team, rank: 1, players: [player2])

      game = FactoryBot.create(:game)
      win = FactoryBot.create(:result, game: game, teams: [player1WinTeam, FactoryBot.create(:team, players: [player2], rank: 2)])
      loss = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 2, players: [player1]), player2WinTeam])

      expect(player1.results.for_game(game).size).to eq(2)
      expect(player1.total_wins(game)).to eq(1)
      expect(player1.wins(game, player2)).to eq(1)
    end
  end

  describe "ties" do
    it "finds ties" do
      player1 = FactoryBot.create(:player)
      player1WinTeam = FactoryBot.create(:team, rank: 1, players: [player1])

      player2 = FactoryBot.create(:player)
      player2WinTeam = FactoryBot.create(:team, rank: 1, players: [player2])

      game = FactoryBot.create(:game)
      tie = FactoryBot.create(:result, game: game, teams: [player1WinTeam, player2WinTeam])

      expect(player1.results.for_game(game).size).to eq(1)
      expect(player1.total_ties(game)).to eq(1)
      expect(player1.ties(game, player2)).to eq(1)
    end
  end

  describe "losses" do
    it "finds losses" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game)
      win = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2)])
      loss = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 2, players: [player]), FactoryBot.create(:team, rank: 1)])
      expect(player.results.for_game(game).size).to eq(2)
      expect(player.results.for_game(game).losses).to eq([loss])
    end
  end

  describe "against" do
    it "finds results against a specific opponent" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game, max_number_of_players_per_team: 2)
      opponent1 = FactoryBot.create(:player)
      opponent2 = FactoryBot.create(:player)
      win_against_opponent1 = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2, players: [opponent1])])
      loss_against_opponent1 = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 2, players: [player]), FactoryBot.create(:team, rank: 1, players: [opponent1])])
      win_against_opponent2 = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player]), FactoryBot.create(:team, rank: 2, players: [opponent2])])
      opponent2_game_against_different_player = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1), FactoryBot.create(:team, rank: 2, players: [opponent2])])
      win_with_opponent1 = FactoryBot.create(:result, game: game, teams: [FactoryBot.create(:team, rank: 1, players: [player, opponent1]), FactoryBot.create(:team, rank: 2)])

      expect(player.results.for_game(game).against(opponent1).sort_by(&:id)).to match_array [win_against_opponent1, loss_against_opponent1]
      expect(player.results.for_game(game).against(opponent2).sort_by(&:id)).to match_array [win_against_opponent2]
    end
  end
end
