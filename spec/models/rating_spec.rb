require "spec_helper"

describe Result do
  describe "to_elo" do
    it "returns an elo player with the correct value" do
      rating = FactoryGirl.build(:rating, :value => 1000)
      rating.to_elo.rating.should == 1000
    end

    it "includes number of games played" do
      player = FactoryGirl.create(:player)
      game = FactoryGirl.create(:game)
      2.times { FactoryGirl.create(:result, :game => game, :winner => player) }

      rating = FactoryGirl.create(:rating, :player => player, :game => game)

      rating.to_elo.games_played.should == 2
    end

    it "includes the pro flag" do
      rating = FactoryGirl.build(:rating, :pro => true)
      rating.to_elo.should be_pro
    end
  end
end
