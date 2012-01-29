FactoryGirl.define do
  factory :rating do
    game
    player
    value Rating::DefaultValue
  end
end
