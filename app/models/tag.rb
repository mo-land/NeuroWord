class Tag < ApplicationRecord
  validates :name, presence: true, length: { maximum: 20 }
  has_many :question_tags, dependent: :destroy
  has_many :questions, through: :question_tags

  # 今後の拡張用スコープ（オートコンプリートの表示順などに使用可能）
  # scope :with_question_count, -> { left_joins(:questions).group(:id).select("tags.*, COUNT(questions.id) as questions_count") }
  # scope :popular, -> { joins(:question_tags).group(:id).order("COUNT(question_tags.id) DESC") }
end
