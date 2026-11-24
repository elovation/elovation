FactoryBot.define do
  factory :player do
    sequence(:name) { |n| "#{Faker::Name.name} #{n}" }
    email { Faker::Internet.email }
  end
end
