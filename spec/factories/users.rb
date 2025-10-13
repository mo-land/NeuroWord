FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
  end

  factory :google_user, class: User do
    name { Faker::Name.name }
    sequence(:email) { |n| "TEST#{n}@example.com" }
    password { "testuser123" }
  end
end
