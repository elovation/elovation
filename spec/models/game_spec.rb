require "spec_helper"

describe Game do
  describe "name" do
    it "has a name" do
      game = FactoryGirl.create(:game, :name => "Go")

      game.name.should == "Go"
    end
  end

  describe "players" do
    it "returns players who have a rating for the game" do
      game = FactoryGirl.create(:game)
      player1 = FactoryGirl.create(:player)
      player2 = FactoryGirl.create(:player)
      FactoryGirl.create(:rating, :game => game, :player => player1)
      FactoryGirl.create(:rating, :game => game, :player => player2)
      game.players.sort_by(&:id).should == [player1, player2]
    end
  end

  describe "recent results" do
    it "returns 5 of the games results" do
      game = FactoryGirl.create(:game)
      10.times { FactoryGirl.create(:result, :game => game) }

      game.recent_results.size.should == 5
    end

    it "returns the 5 most recently created results" do
      newer_results = nil
      game = FactoryGirl.create(:game)

      Timecop.freeze(3.days.ago) do
        5.times.map { FactoryGirl.create(:result, :game => game) }
      end

      Timecop.freeze(1.day.ago) do
        newer_results = 5.times.map { FactoryGirl.create(:result, :game => game) }
      end

      game.recent_results.sort.should == newer_results.sort
    end

    it "orders results by created_at, descending" do
      game = FactoryGirl.create(:game)
      old = new = nil

      Timecop.freeze(2.days.ago) do
        old = FactoryGirl.create(:result, :game => game)
      end

      Timecop.freeze(1.days.ago) do
        new = FactoryGirl.create(:result, :game => game)
      end

      game.recent_results.should == [new, old]
    end
  end

  describe "top_ratings" do
    it "returns 5 ratings associated with the game" do
      game = FactoryGirl.create(:game)
      10.times { FactoryGirl.create(:rating, :game => game) }

      game.top_ratings.count.should == 5
    end

    it "orders ratings by value, descending" do
      game = FactoryGirl.create(:game)
      rating2 = FactoryGirl.create(:rating, :game => game, :value => 2)
      rating3 = FactoryGirl.create(:rating, :game => game, :value => 3)
      rating1 = FactoryGirl.create(:rating, :game => game, :value => 1)

      game.top_ratings.should == [rating3, rating2, rating1]
    end
  end

  describe "all_ratings" do
    it "orders all ratings by value, descending" do
      game = FactoryGirl.create(:game)
      rating2 = FactoryGirl.create(:rating, :game => game, :value => 2)
      rating3 = FactoryGirl.create(:rating, :game => game, :value => 3)
      rating1 = FactoryGirl.create(:rating, :game => game, :value => 1)
      rating4 = FactoryGirl.create(:rating, :game => game, :value => 4)
      rating5 = FactoryGirl.create(:rating, :game => game, :value => 5)
      rating6 = FactoryGirl.create(:rating, :game => game, :value => 6)

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
        game = FactoryGirl.build(:game, :name => nil)

        game.should_not be_valid
        game.errors[:name].should == ["can't be blank"]
      end
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      game = FactoryGirl.create(:game)
      rating = FactoryGirl.create(:rating, :game => game)
      result = FactoryGirl.create(:result, :game => game)

      game.destroy

      Rating.find_by_id(rating.id).should be_nil
      Result.find_by_id(result.id).should be_nil
    end
  end

  describe "wins and losses" do
    before do
      @game1 = FactoryGirl.create(:game)
      @game2 = FactoryGirl.create(:game)
      @player1 = FactoryGirl.create(:player)
      @player2 = FactoryGirl.create(:player)
      @player3 = FactoryGirl.create(:player)

      FactoryGirl.create(:result, :game => @game1, :winner => @player1, :loser => @player2)
      FactoryGirl.create(:result, :game => @game1, :winner => @player1, :loser => @player3)
      FactoryGirl.create(:result, :game => @game1, :winner => @player2, :loser => @player3)

      FactoryGirl.create(:result, :game => @game2, :winner => @player1, :loser => @player2)
    end

    it "counts wins and losses" do
      @game1.wins_and_losses.should == {
        @player1.id => { :wins => 2, :losses => 0 },
        @player2.id => { :wins => 1, :losses => 1 },
        @player3.id => { :wins => 0, :losses => 2 },
      }

      @game2.wins_and_losses.should == {
        @player1.id => { :wins => 1, :losses => 0 },
        @player2.id => { :wins => 0, :losses => 1 },
        @player3.id => { :wins => 0, :losses => 0 },
      }
    end

    it "counts wins and losses against player" do
      @game1.wins_and_losses_against(@player2).should == {
        @player1.id => { :wins => 1, :losses => 0 },
        @player2.id => { :wins => 0, :losses => 0 },
        @player3.id => { :wins => 0, :losses => 1 },
      }
    end
  end
end
