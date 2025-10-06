class OriginWord < ApplicationRecord
  belongs_to :question
  has_many :related_words, dependent: :destroy
end
