FactoryGirl.define do
  factory :rating do
    game
    player
    pro false
    value { game.rater.default_attributes[:value] }
  end
end
