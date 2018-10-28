FactoryBot.define do
  factory :contact do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    star { Faker::Boolean.boolean }

    trait :invalid do
      first_name { nil }
      last_name { nil }
      phone_number { nil }
    end

    trait :with_static_phone do
      sequence(:phone_number) do |n|
        ['994-125-1650 x6404', '975-793-9864 x95700', '(631) 588-3973 x3810', '1-197-095-3942',
          '(755) 898-8014 x559', '(359) 089-9321 x2285', '(135) 395-9148 x35416', '843.409.2784 x52931',
          '1-760-501-0300', '271-389-3699', '588-646-4680 x47725', '1-998-508-2602 x7140', '(498) 078-6069 x33923',
          '666.221.4131', '(600) 497-7194 x80760', '1-219-025-3724 x262', '916-065-0278 x5829', '1-652-904-4223 x866',
          '227.049.8680', '(779) 911-4189'][n % 20]
      end
    end
  end
end
