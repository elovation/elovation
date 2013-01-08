FactoryGirl.define do
  factory :team do
    players { [FactoryGirl.build(:player)] }
  end
end
