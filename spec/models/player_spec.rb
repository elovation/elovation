require "spec_helper"

describe Player do
  describe "validations" do
    context "name" do
      it "is required" do
        player = FactoryGirl.build(:player, :name => nil)

        player.should_not be_valid
        player.errors[:name].should == ["can't be blank"]
      end

      it "must be unique" do
        FactoryGirl.create(:player, :name => "Drew")
        player = FactoryGirl.build(:player, :name => "Drew")

        player.should_not be_valid
        player.errors[:name].should == ["has already been taken"]
      end
    end
  end

  describe "name" do
    it "has a name" do
      player = FactoryGirl.create(:player, :name => "Drew")

      player.name.should == "Drew"
    end
  end

  describe "recent_results" do
    it "returns 5 of the player's results" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      10.times { FactoryGirl.create(:result, :game => game, :winner => player) }

      player.recent_results.size.should == 5
    end

    it "returns the 5 most recently created results" do
      newer_results = nil
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)

      Timecop.freeze(3.days.ago) do
        5.times.map { FactoryGirl.create(:result, :game => game, :winner => player) }
      end

      Timecop.freeze(1.day.ago) do
        newer_results = 5.times.map { FactoryGirl.create(:result, :game => game, :winner => player) }
      end

      player.recent_results.sort.should == newer_results.sort
    end

    it "orders results by created_at, descending" do
      game = FactoryGirl.create(:game)
      player = FactoryGirl.create(:player)
      old = new = nil

      Timecop.freeze(2.days.ago) do
        old = FactoryGirl.create(:result, :game => game, :winner => player)
      end

      Timecop.freeze(1.days.ago) do
        new = FactoryGirl.create(:result, :game => game, :winner => player)
      end

      player.recent_results.should == [new, old]
    end
  end

  describe "destroy" do
    it "deletes related ratings and results" do
      player = FactoryGirl.create(:player)
      rating = FactoryGirl.create(:rating, :player => player)
      result = FactoryGirl.create(:result, :winner => player)

      player.destroy

      Rating.find_by_id(rating.id).should be_nil
      Result.find_by_id(result.id).should be_nil
    end
  end

  describe "ratings" do
    describe "find_or_create" do
      it "returns the rating if it exists" do
        player = FactoryGirl.create(:player)
        game = FactoryGirl.create(:game)
        rating = FactoryGirl.create(:rating, :game => game, :player => player)

        expect do
          found_rating = player.ratings.find_or_create(game)
          found_rating.should == rating
        end.to_not change { player.ratings.count }
      end

      it "creates a rating and returns it if it doesn't exist" do
        player = FactoryGirl.create(:player)
        game = FactoryGirl.create(:game)

        expect do
          player.ratings.find_or_create(game).should_not be_nil
        end.to change { player.ratings.count }.by(1)
      end
    end
  end

  describe "wins" do
    it "finds wins" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      win = FactoryGirl.create(:result, :game => game, :winner => player)
      loss = FactoryGirl.create(:result, :game => game, :loser => player)
      player.results.for_game(game).size.should == 2
      player.results.for_game(game).wins.should == [win]
    end
  end

  describe "losses" do
    it "finds losses" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      win = FactoryGirl.create(:result, :game => game, :winner => player)
      loss = FactoryGirl.create(:result, :game => game, :loser => player)
      player.results.for_game(game).size.should == 2
      player.results.for_game(game).losses.should == [loss]
    end
  end
end
