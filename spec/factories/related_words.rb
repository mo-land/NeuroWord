FactoryBot.define do
  factory :related_word do
    origin_word { nil }
    related_word { "MyString" }
  end
end
