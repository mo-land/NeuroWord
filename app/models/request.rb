class Request < ApplicationRecord
  belongs_to :question
  belongs_to :user

  has_many :request_responses, dependent: :destroy

  enum status: { incompleted: 0, completed: 1 }
end
