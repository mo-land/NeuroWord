class Question < ApplicationRecord
  validates :title, presence: true, length: { maximum: 40 }
  validates :description, presence: true, length: { maximum: 150 }

  belongs_to :user
end
