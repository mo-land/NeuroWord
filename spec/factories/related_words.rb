FactoryBot.define do
  factory :related_word do
    related_word { "MyString" }
    association :origin_word
  end
end
