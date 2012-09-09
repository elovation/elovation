require 'spec_helper'

describe Challenge do
  describe "as_json" do
    it "returns the json representation of the challenge" do
      game = FactoryGirl.build(:game, :name => "RockPaperScissors")
      challenger = FactoryGirl.build(:player, :name => "Jane")
      challengee = FactoryGirl.build(:player, :name => "John")

      Timecop.freeze(Time.now) do
        challenge = FactoryGirl.create(:challenge, :game => game, :challenger => challenger, :challengee => challengee)

        challenge.as_json.should == {
          :challenger => challenger.name,
          :challengee => challengee.name,
          :expires_at => 5.days.from_now.utc.to_s,
        }
      end
    end
  end

  describe "validations" do
    context "challenger" do
      it "is required" do
        FactoryGirl.build(:challenge, :challenger => nil).should_not be_valid
      end

      it "is not already in a challenge" do
        game = FactoryGirl.create(:game)
        player = FactoryGirl.create(:player)

        FactoryGirl.create(:challenge, :game => game, :challenger => player)
        FactoryGirl.build(:challenge, :game => game, :challenger => player).should_not be_valid
      end
    end

    context "challengee" do
      it "is required" do
        FactoryGirl.build(:challenge, :challengee => nil).should_not be_valid
      end

      it "cannot be the same as the challenger" do
        player = FactoryGirl.build(:player)
        challenge = FactoryGirl.build(:challenge, :challenger => player, :challengee => player).should_not be_valid
      end
    end

    context "game" do
      it "is required" do
        FactoryGirl.build(:challenge, :game => nil).should_not be_valid
      end
    end
  end

  describe "expires_at" do
    it "is based on created_at" do
      challenge = FactoryGirl.create(:challenge)
      challenge.expires_at.should == challenge.created_at + 5.days
    end
  end

  describe "class" do
    it "finds active challenges for result" do
      game_1 = FactoryGirl.create(:game)
      game_2 = FactoryGirl.create(:game)
      player_1 = FactoryGirl.create(:player)
      player_2 = FactoryGirl.create(:player)
      player_3 = FactoryGirl.create(:player)

      challenge = FactoryGirl.create(:challenge, :game => game_1, :challenger => player_1, :challengee => player_2)
      result = FactoryGirl.build(:result, :game => game_1, :winner => player_1, :loser => player_2)
      Challenge.find_active_challenges_for_result(result).should == [ challenge ]

      challenge.result = result
      challenge.save
      Challenge.find_active_challenges_for_result(result).should == []

      challenge_1 = FactoryGirl.create(:challenge, :game => game_2, :challenger => player_2, :challengee => player_1)
      challenge_2 = FactoryGirl.create(:challenge, :game => game_2, :challenger => player_1, :challengee => player_2)
      result = FactoryGirl.build(:result, :game => game_2, :winner => player_1, :loser => player_2)
      Challenge.find_active_challenges_for_result(result).should == [ challenge_1, challenge_2 ]

      result = FactoryGirl.build(:result, :game => game_1, :winner => player_1, :loser => player_3)
      Challenge.find_active_challenges_for_result(result).should == []
    end
  end
end
