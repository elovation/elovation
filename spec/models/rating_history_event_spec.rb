require "spec_helper"

describe RatingHistoryEvent do
  describe "value" do
    it "should return an integer value for elo games" do
      game = FactoryGirl.create(:elo_game)
      rating = FactoryGirl.create(:rating, :value => 1000.0, :game => game)
      history_event = FactoryGirl.build(:rating_history_event, :value => 1000.0, :rating => rating)
      history_event.value.class.should == Fixnum
      history_event.value.to_s.should == "1000"
    end

    it "should return a big decimal value for trueskill games" do
      game = FactoryGirl.create(:trueskill_game)
      rating = FactoryGirl.create(:rating, :value => 1000.1234, :game => game)
      history_event = FactoryGirl.build(:rating_history_event, :value => 1000.1234, :rating => rating)
      history_event.value.class.should == BigDecimal
      history_event.value.to_s.should == BigDecimal("1000.1234").to_s
    end
  end
end
