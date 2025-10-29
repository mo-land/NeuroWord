class OriginWord < ApplicationRecord
  belongs_to :question
  has_many :related_words, dependent: :destroy

  validates :origin_word, presence: true, length: { maximum: 50 }
  validate :uniqueness_within_question

  private

  def uniqueness_within_question
    return unless origin_word.present? && question_id.present?

    # 同じ問題内の他のorigin_wordと重複チェック
    existing_origin_words = OriginWord.where(question_id: question_id, origin_word: origin_word)
                                       .where.not(id: id) # 自分自身は除外

    if existing_origin_words.exists?
      errors.add(:origin_word, "は既にこの問題内で使用されています")
    end
  end
end
