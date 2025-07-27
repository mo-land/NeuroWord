class Tag < ApplicationRecord
  validates :name, presence: true, length: { maximum: 25 }
  has_many :question_tags, dependent: :destroy
  has_many :questions, through: :question_tags
end
