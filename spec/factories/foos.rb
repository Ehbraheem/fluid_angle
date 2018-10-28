FactoryBot.define do
  factory :foo_faked, class: 'Foo' do
    name { Faker::Name.name }

    trait :invalid do
      name { nil }
    end
  end

  factory :foo, parent: :foo_faked 
  
end
