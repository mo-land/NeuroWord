FactoryBot.define do
  factory :question do
    sequence(:title) { |n| "question#{n}" }
    description { '問題説明' }
    association :user
  end
end
