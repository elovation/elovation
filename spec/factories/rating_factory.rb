FactoryGirl.define do
  factory :rating do
    game
    player
    pro false
    value Rating::DefaultValue
  end
end
