FactoryBot.define do
  factory :game_record do
    total_matches { '4' }
    accuracy { '0.6' }
    completion_time_seconds { '25' }
    given_up { 'false' }
    association :user
    association :question
  end
end
