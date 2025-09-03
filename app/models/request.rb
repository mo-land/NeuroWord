class Request < ApplicationRecord
  belongs_to :question
  belongs_to :user

  has_many :request_responses, dependent: :destroy

  enum status: { incompleted: 0, completed: 1 }

  # Runsackホワイトリスト
  def self.ransackable_attributes(auth_object = nil)
    [ "title", "content", "status" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user", "question" ]
  end
end
