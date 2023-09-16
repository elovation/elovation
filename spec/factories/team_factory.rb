FactoryBot.define do
  factory :team do
    players { [FactoryBot.build(:player)] }
  end
end
