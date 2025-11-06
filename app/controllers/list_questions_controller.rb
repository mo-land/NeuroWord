class ListQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question

  def create
    list = current_user.favorite_list # ユーザーのお気に入りリストを取得
    list_question = list.list_questions.new(question: @question)

    if list_question.save
      redirect_back fallback_location: @question, notice: "お気に入りに追加しました！"
    else
      redirect_back fallback_location: @question, alert: "すでにお気に入りに登録されています。"
    end
  end

  def destroy
    list = current_user.favorite_list
    list_question = list.list_questions.find_by(question_id: @question.id)

    if list_question&.destroy
      redirect_back fallback_location: @question, notice: "お気に入りを解除しました。"
    else
      redirect_back fallback_location: @question, alert: "お気に入り解除に失敗しました。"
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
