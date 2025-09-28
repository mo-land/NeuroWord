FactoryBot.define do
  factory :card_set do
    origin_word { "起点カード" }
    related_words { [ "関連語1", "関連語2" ] }
    association :question
  end
end
