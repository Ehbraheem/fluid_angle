FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    username { Faker::Internet.user_name }
    nickname { Faker::Twitter.screen_name }
    password { Faker::Internet.password }
  end
end
