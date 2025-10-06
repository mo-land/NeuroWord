module QuestionAuthorizable
  extend ActiveSupport::Concern

  private

  def authorize_question_owner!
    unless @question.user_id == current_user.id
      redirect_to root_path, alert: "権限がありません"
    end
  end
end
