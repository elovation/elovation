require "rails_helper"

RSpec.describe Player, type: :model do
  describe "as_json" do
    it "returns the json representation of the player" do
      player =
        FactoryBot.build(:player, name: "John Doe", email: "foo@example.com")

      player.as_json.should == { name: "John Doe", email: "foo@example.com" }
    end
  end

  describe "validations" do
    context("name") do
      it "is required" do
        player = FactoryBot.build(:player, name: nil)

        player.should_not(be_valid)
        player.errors[:name].should == ["can't be blank"]
      end

      it "must be unique" do
        FactoryBot.create(:player, name: "Drew")
        player = FactoryBot.build(:player, name: "Drew")

        player.should_not(be_valid)
        player.errors[:name].should == ["has already been taken"]
      end
    end

    context("email") do
      it "can be blank" do
        player = FactoryBot.build(:player, email: "")
        player.should(be_valid)
      end

      it "must be a valid email format" do
        player = Player.new
        player.email = "invalid-email-address"
        player.should_not(be_valid)
        player.errors[:email].should == ["is invalid"]
        player.email = "valid@example.com"
        player.valid?
        player.errors[:email].should == []
      end
    end
  end

  describe "name" do
    it "has a name" do
      player = FactoryBot.create(:player, name: "Drew")

      player.name.should == "Drew"
    end
  end

  describe "recent_results" do
    it "returns 5 of the player's results" do
      game = FactoryBot.create(:game)
      player = FactoryBot.create(:player)

      10.times do
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player]),
            FactoryBot.create(:team, rank: 2)
          ]
        )
      end

      player.recent_results.size.should == 5
    end

    it "returns the 5 most recently created results" do
      newer_results = nil
      game = FactoryBot.create(:game)
      player = FactoryBot.create(:player)

      Timecop.freeze(3.days.ago) do
        5.times do
          FactoryBot.create(
            :result,
            game: game,
            teams: [
              FactoryBot.create(:team, rank: 1, players: [player]),
              FactoryBot.create(:team, rank: 2)
            ]
          )
        end
      end

      Timecop.freeze(1.day.ago) do
        newer_results =
          5.times.map do
            FactoryBot.create(
              :result,
              game: game,
              teams: [
                FactoryBot.create(:team, rank: 1, players: [player]),
                FactoryBot.create(:team, rank: 2)
              ]
            )
          end
      end

      player.recent_results.sort.should == newer_results.sort
    end

    it "orders results by created_at, descending" do
      game = FactoryBot.create(:game)
      player = FactoryBot.create(:player)
      old = new = nil

      Timecop.freeze(2.days.ago) do
        old =
          FactoryBot.create(
            :result,
            game: game,
            teams: [
              FactoryBot.create(:team, rank: 1, players: [player]),
              FactoryBot.create(:team, rank: 2)
            ]
          )
      end

      Timecop.freeze(1.days.ago) do
        new =
          FactoryBot.create(
            :result,
            game: game,
            teams: [
              FactoryBot.create(:team, rank: 1, players: [player]),
              FactoryBot.create(:team, rank: 2)
            ]
          )
      end

      player.recent_results.should == [new, old]
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      player = FactoryBot.create(:player)
      rating = FactoryBot.create(:rating, player: player)
      result =
        FactoryBot.create(
          :result,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player]),
            FactoryBot.create(:team, rank: 2)
          ]
        )

      player.destroy

      Rating.find_by_id(rating.id).should(be_nil)
      Result.find_by_id(result.id).should(be_nil)
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
          found_rating.should == rating
        end.to_not(change { player.ratings.count })
      end

      it "creates a rating and returns it if it doesn't exist" do
        player = FactoryBot.create(:player)
        game = FactoryBot.create(:game)

        expect { player.ratings.find_or_create(game).should_not(be_nil) }.to(
          change { player.ratings.count }.by(1)
        )
      end
    end
  end

  describe "rewind_rating!" do
    it "resets the player's rating to the previous rating" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game)
      rating =
        FactoryBot.create(:rating, game: game, player: player, value: 1002)
      FactoryBot.create(:rating_history_event, rating: rating, value: 1001)
      FactoryBot.create(:rating_history_event, rating: rating, value: 1002)

      player.rewind_rating!(game)

      player.ratings.where(game_id: game.id).first.value.should == 1001
    end
  end

  describe "wins" do
    it "finds wins" do
      player1 = FactoryBot.create(:player)
      player1WinTeam = FactoryBot.create(:team, rank: 1, players: [player1])

      player2 = FactoryBot.create(:player)
      player2WinTeam = FactoryBot.create(:team, rank: 1, players: [player2])

      game = FactoryBot.create(:game)
      win =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            player1WinTeam,
            FactoryBot.create(:team, players: [player2], rank: 2)
          ]
        )
      loss =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 2, players: [player1]),
            player2WinTeam
          ]
        )

      player1.results.for_game(game).size.should == 2
      player1.total_wins(game).should == 1
      player1.wins(game, player2).should == 1
    end
  end

  describe "ties" do
    it "finds ties" do
      player1 = FactoryBot.create(:player)
      player1WinTeam = FactoryBot.create(:team, rank: 1, players: [player1])

      player2 = FactoryBot.create(:player)
      player2WinTeam = FactoryBot.create(:team, rank: 1, players: [player2])

      game = FactoryBot.create(:game)
      tie =
        FactoryBot.create(
          :result,
          game: game,
          teams: [player1WinTeam, player2WinTeam]
        )

      player1.results.for_game(game).size.should == 1
      player1.total_ties(game).should == 1
      player1.ties(game, player2).should == 1
    end
  end

  describe "losses" do
    it "finds losses" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game)
      win =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player]),
            FactoryBot.create(:team, rank: 2)
          ]
        )
      loss =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 2, players: [player]),
            FactoryBot.create(:team, rank: 1)
          ]
        )
      player.results.for_game(game).size.should == 2
      player.results.for_game(game).losses.should == [loss]
    end
  end

  describe "against" do
    it "finds results against a specific opponent" do
      player = FactoryBot.create(:player)
      game = FactoryBot.create(:game, max_number_of_players_per_team: 2)
      opponent1 = FactoryBot.create(:player)
      opponent2 = FactoryBot.create(:player)
      win_against_opponent1 =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player]),
            FactoryBot.create(:team, rank: 2, players: [opponent1])
          ]
        )
      loss_against_opponent1 =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 2, players: [player]),
            FactoryBot.create(:team, rank: 1, players: [opponent1])
          ]
        )
      win_against_opponent2 =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player]),
            FactoryBot.create(:team, rank: 2, players: [opponent2])
          ]
        )
      opponent2_game_against_different_player =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 1),
            FactoryBot.create(:team, rank: 2, players: [opponent2])
          ]
        )
      win_with_opponent1 =
        FactoryBot.create(
          :result,
          game: game,
          teams: [
            FactoryBot.create(:team, rank: 1, players: [player, opponent1]),
            FactoryBot.create(:team, rank: 2)
          ]
        )

      player
        .results
        .for_game(game)
        .against(opponent1)
        .sort_by(&:id)
        .should(match_array([win_against_opponent1, loss_against_opponent1]))
      player
        .results
        .for_game(game)
        .against(opponent2)
        .sort_by(&:id)
        .should(match_array([win_against_opponent2]))
    end
  end
end
