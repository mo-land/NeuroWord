class ListQuestion < ApplicationRecord
  belongs_to :list
  belongs_to :question

  validates :list_id, uniqueness: { scope: :question_id }
end
