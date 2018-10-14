FactoryGirl.define do
  factory :foo_faked, class: 'Foo' do
    name { Faker::Name.name }
  end

  factory :foo, parent: :foo_faked 
  
end
