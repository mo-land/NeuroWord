class GameRecord < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :total_matches, numericality: { greater_than_or_equal_to: 0 }
  validates :accuracy, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :completion_time_seconds, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # 直近2週間以内のレコード
  scope :within_two_weeks, -> { where("created_at >= ?", 2.weeks.ago) }

  # 正答率80%以上のレコード
  scope :high_accuracy, -> { where("accuracy >= ?", 80) }

  # 特定のユーザーにとって「理解済み」とされる問題IDを取得
  # 直近2週間以内に正答率80%以上となった問題のIDを返す
  def self.understood_question_ids_for(user)
    where(user: user)
      .within_two_weeks
      .high_accuracy
      .distinct
      .pluck(:question_id)
  end
end
