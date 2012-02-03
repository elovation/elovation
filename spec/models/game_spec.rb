require "spec_helper"

describe Game do
  describe "name" do
    it "has a name" do
      game = FactoryGirl.create(:game, :name => "Go")

      game.name.should == "Go"
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
end
