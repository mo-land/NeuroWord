class CardForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :origin_word, :string
  attribute :related_word, :string
  attribute :question_id, :integer

  validates :origin_word, presence: true, length: { maximum: 50 }
  validates :related_word, presence: true, length: { maximum: 100 }
  validate :related_word_uniqueness_within_question

  private

  def related_word_uniqueness_within_question
    return unless question_id.present? && related_word.present?

    question = Question.find(question_id)
    # 同じ問題内の全てのrelated_wordsと重複チェック
    existing_related_words = RelatedWord.joins(:origin_word)
                                        .where(origin_words: { question_id: question.id })
                                        .where(related_word: related_word)

    if existing_related_words.exists?
      errors.add(:related_word, "は既にこの問題内で使用されています")
    end
  end
end
