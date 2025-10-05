class OriginWord < ApplicationRecord
  belongs_to :question
  has_many :related_words, dependent: :destroy

  validates :origin_word, presence: true, length: { maximum: 50 }
end
