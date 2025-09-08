class RequestResponse < ApplicationRecord
  belongs_to :request
  belongs_to :user

  validates :content, presence: true, length: { maximum: 500 }
  validates :is_completed, inclusion: { in: [ true, false ] }

  after_create :update_request_status_if_completed

  private

  def update_request_status_if_completed
    return unless is_completed?

    request.update!(status: :completed)
  end
end
