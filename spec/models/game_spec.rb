require "spec_helper"

describe Game do
  describe "name" do
    it "has a name" do
      game = FactoryGirl.create(:game, name: "Go")

      game.name.should == "Go"
    end
  end

  describe "players" do
    it "returns players who have a rating for the game" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      FactoryGirl.create(:rating, game: game, player: player1)
      FactoryGirl.create(:rating, game: game, player: player2)
      game.players.sort_by(&:id).should == [player1, player2]
    end
  end

  describe "recent results" do
    it "returns 10 of the games results" do
      game = FactoryGirl.create(:game)
      21.times { FactoryGirl.create(:result, game: game) }

      game.recent_results.size.should == 20
    end

    it "returns the 20 most recently created results" do
      newer_results = nil
      game = FactoryGirl.create(:game)

      Timecop.freeze(3.days.ago) do
        5.times.map { FactoryGirl.create(:result, game: game) }
      end

      Timecop.freeze(1.day.ago) do
        newer_results = 20.times.map { FactoryGirl.create(:result, game: game) }
      end

      game.recent_results.sort.should == newer_results.sort
    end

    it "orders results by created_at, descending" do
      game = FactoryGirl.create(:game)
      old = new = nil

      Timecop.freeze(2.days.ago) do
        old = FactoryGirl.create(:result, game: game)
      end

      Timecop.freeze(1.days.ago) do
        new = FactoryGirl.create(:result, game: game)
      end

      game.recent_results.should == [new, old]
    end

    it "orders games by updated_at, descending" do
      game1 = FactoryGirl.create(:game)
      game2 = FactoryGirl.create(:game)

      expect(Game.all).to eq([game2, game1])
    end
  end

  describe "top_ratings" do
    it "returns 5 ratings associated with the game" do
      game = FactoryGirl.create(:game)
      10.times { FactoryGirl.create(:rating, game: game) }

      game.top_ratings.count.should == 5
    end

    it "orders ratings by value, descending" do
      game = FactoryGirl.create(:game)
      rating2 = FactoryGirl.create(:rating, game: game, value: 2)
      rating3 = FactoryGirl.create(:rating, game: game, value: 3)
      rating1 = FactoryGirl.create(:rating, game: game, value: 1)

      game.top_ratings.should == [rating3, rating2, rating1]
    end
  end

  describe "all_ratings" do
    it "orders all ratings by value, descending" do
      game = FactoryGirl.create(:game)
      rating2 = FactoryGirl.create(:rating, game: game, value: 2)
      rating3 = FactoryGirl.create(:rating, game: game, value: 3)
      rating1 = FactoryGirl.create(:rating, game: game, value: 1)
      rating4 = FactoryGirl.create(:rating, game: game, value: 4)
      rating5 = FactoryGirl.create(:rating, game: game, value: 5)
      rating6 = FactoryGirl.create(:rating, game: game, value: 6)

      game.all_ratings.should == [
        rating6,
        rating5,
        rating4,
        rating3,
        rating2,
        rating1
      ]
    end
  end

  describe "validations" do
    context "name" do
      it "must be present" do
        game = FactoryGirl.build(:game, name: nil)

        game.should_not be_valid
        game.errors[:name].should == ["can't be blank"]
      end
    end

    context "min_number_of_teams" do
      it "can be 2" do
        game = FactoryGirl.build(:game, min_number_of_teams: 2)

        game.should be_valid
      end

      it "can be greater than 2" do
        game = FactoryGirl.build(:game, min_number_of_teams: 3, max_number_of_teams: 3)

        game.should be_valid
      end

      it "cannot be less than 2" do
        game = FactoryGirl.build(:game, min_number_of_teams: 1)

        game.should_not be_valid
        game.errors[:min_number_of_teams].should == ["must be greater than or equal to 2"]
      end

      it "cannot be nil" do
        game = FactoryGirl.build(:game, min_number_of_teams: nil)

        game.should_not be_valid
        game.errors[:min_number_of_teams].should == ["is not a number"]
      end
    end

    context "max_number_of_teams" do
      it "can be equal to min number of teams" do
        game = FactoryGirl.build(:game, min_number_of_teams: 2, max_number_of_teams: 2)

        game.should be_valid
      end

      it "can be greater than the min number of teams" do
        game = FactoryGirl.build(:game, min_number_of_teams: 2, max_number_of_teams: 3)

        game.should be_valid
      end

      it "can be nil" do
        game = FactoryGirl.build(:game, min_number_of_teams: 2, max_number_of_teams: nil)

        game.should be_valid
      end

      it "cannot be less than the min number of teams" do
        game = FactoryGirl.build(:game, min_number_of_teams: 2, max_number_of_teams: 1)

        game.should_not be_valid
        game.errors[:max_number_of_teams].should == ["cannot be less than the minimum"]
      end
    end

    context "min_number_of_players_per_team" do
      it "can be 1" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: 1)

        game.should be_valid
      end

      it "can be greater than 1" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 2)

        game.should be_valid
      end

      it "cannot be less than 1" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: 0)

        game.should_not be_valid
        game.errors[:min_number_of_players_per_team].should == ["must be greater than or equal to 1"]
      end

      it "cannot be nil" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: nil)

        game.should_not be_valid
        game.errors[:min_number_of_players_per_team].should == ["is not a number"]
      end
    end

    context "max_number_of_players_per_team" do
      it "can be equal to the min number of players per team" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 2)

        game.should be_valid
      end

      it "can be greater than the min number of players per team" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 3)

        game.should be_valid
      end

      it "can be nil" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 3)

        game.should be_valid
      end

      it "cannot be less than the min number of players per team" do
        game = FactoryGirl.build(:game, min_number_of_players_per_team: 2, max_number_of_players_per_team: 1)

        game.should_not be_valid
        game.errors[:max_number_of_teams].should == ["cannot be less than the minimum"]
      end
    end

    context "allow_ties" do
      it "can be true" do
        game = FactoryGirl.build(:game, allow_ties: true)

        game.should be_valid
      end

      it "can be false" do
        game = FactoryGirl.build(:game, allow_ties: false)

        game.should be_valid
      end

      it "cannot be nil" do
        game = FactoryGirl.build(:game, allow_ties: nil)

        game.should_not be_valid
        game.errors[:allow_ties].should == ["must be selected"]
      end
    end

    context "rating_type" do
      it "must be present" do
        game = FactoryGirl.build(:game, rating_type: nil)

        game.should_not be_valid
        game.errors[:rating_type].should == ["must be a valid rating type"]
      end

      it "can be elo" do
        game = FactoryGirl.build(:game, rating_type: "elo")

        game.should be_valid
      end

      it "can be trueskill" do
        game = FactoryGirl.build(:game, rating_type: "trueskill")

        game.should be_valid
      end

      it "cannot be anything else" do
        game = FactoryGirl.build(:game, rating_type: "foo")

        game.should_not be_valid
        game.errors[:rating_type].should == ["must be a valid rating type"]
      end

      it "cannot be changed" do
        game = FactoryGirl.build(:game, rating_type: "elo")
        game.save!

        game.rating_type = "trueskill"
        game.should_not be_valid
        game.errors[:rating_type].should == ["cannot be changed"]
      end
    end

    describe "with elo rating type" do
      it "does not allow more than 2 teams" do
        game = FactoryGirl.build(:game, rating_type: "elo", max_number_of_teams: 3)
        game.should_not be_valid
        game.errors[:rating_type].should == ["Elo can only be used with 1v1 games"]
      end

      it "does not allow more than 1 player per team" do
        game = FactoryGirl.build(:game, rating_type: "elo", max_number_of_players_per_team: 2)
        game.should_not be_valid
        game.errors[:rating_type].should == ["Elo can only be used with 1v1 games"]
      end
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, game: game)
      result = FactoryGirl.create(:result, game: game)

      game.destroy

      Rating.find_by_id(rating.id).should be_nil
      Result.find_by_id(result.id).should be_nil
    end
  end

  describe "recalculate_ratings!" do
    it "wipes out the rating history, and recalculates the results" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      player3 = FactoryGirl.create(:player)
      5.times do
        team1 = FactoryGirl.create(:team, rank: 1, players: [player1])
        team2 = FactoryGirl.create(:team, rank: 2, players: [player2])
        result = FactoryGirl.create(:result, game: game, teams: [team1, team2])
        game.rater.update_ratings game, result.teams
      end
      4.times do
        team1 = FactoryGirl.create(:team, rank: 1, players: [player3])
        team2 = FactoryGirl.create(:team, rank: 2, players: [player2])
        result = FactoryGirl.create(:result, game: game, teams: [team1, team2])
        game.rater.update_ratings game, result.teams
      end

      previous_ratings = game.all_ratings.to_a

      game.recalculate_ratings!

      attrs = ->(rating){[rating.player_id, rating.value, rating.trueskill_mean, rating.trueskill_deviation]}
      previous_ratings.map(&:id).should_not == game.all_ratings.map(&:id)
      previous_ratings.map(&attrs).should == game.all_ratings.map(&attrs)
    end
  end
end
