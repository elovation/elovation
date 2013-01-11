FactoryGirl.define do
  factory :rating do
    game
    player
    pro false
    value { game.rater.default_attributes[:value] }
    trueskill_mean { game.rater.default_attributes[:trueskill_mean] }
    trueskill_deviation { game.rater.default_attributes[:trueskill_deviation] }
  end
end
