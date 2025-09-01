class GameRecord < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :total_matches, numericality: { greater_than_or_equal_to: 0 }
  validates :accuracy, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :completion_time_seconds, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
