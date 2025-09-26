FactoryBot.define do
  factory :request_response do
    content { '完了しました！' }
    is_completed { 'true' }
    association :user
    association :request
  end
end
