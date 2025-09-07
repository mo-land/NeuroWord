class RequestResponse < ApplicationRecord
  belongs_to :request
  belongs_to :user

  validates :content, presence: true, length: { maximum: 500 }
  validates :is_completed, inclusion: { in: [true, false] }

  validate :only_one_completed_response, if: :is_completed?

  after_create :update_request_status_if_completed

  private

  def only_one_completed_response
    if request.request_responses.where(is_completed: true).where.not(id: id).exists?
      errors.add(:is_completed, "この依頼は完了しているため返信できません")
    end
  end

  def update_request_status_if_completed
    return unless is_completed?

    request.update!(status: :completed)
  end
end
