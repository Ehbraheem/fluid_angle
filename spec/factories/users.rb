FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    username { Faker::Internet.user_name }
    nickname { Faker::Twitter.screen_name }
    password { Faker::Internet.password }

    trait :invalid do
      email { nil }
      username { nil }
      password { nil }
    end
  end
end
