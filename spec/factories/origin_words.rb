FactoryBot.define do
  factory :origin_word do
    origin_word { "起点語" }
    association :question

    transient do
      related_words_count { 0 }
      related_words_list { [] }
    end

    after(:create) do |origin_word, evaluator|
      next if evaluator.related_words_list.empty? && evaluator.related_words_count.zero?

      if evaluator.related_words_list.any?
        evaluator.related_words_list.each do |word|
          create(:related_word, origin_word: origin_word, related_word: word)
        end
        next
      end

      create_list(:related_word, evaluator.related_words_count, origin_word: origin_word)
    end
  end
end
