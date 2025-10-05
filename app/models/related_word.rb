class RelatedWord < ApplicationRecord
  belongs_to :origin_word

  validates :related_word, uniqueness: { scope: :origin_word_id }
  validate :uniqueness_within_question

  private

  def uniqueness_within_question
    return unless origin_word&.question

    # 同じ問題内の他のorigin_wordに紐づくrelated_wordsと重複チェック
    question = origin_word.question
    existing_related_words = RelatedWord.joins(:origin_word)
                                        .where(origin_words: { question_id: question.id })
                                        .where(related_word: related_word)
                                        .where.not(id: id) # 自分自身は除外

    if existing_related_words.exists?
      errors.add(:related_word, "は既にこの問題内で使用されています")
    end
  end
end
