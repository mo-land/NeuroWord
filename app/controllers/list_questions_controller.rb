class ListQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question

  def create
    list = current_user.favorite_list # ユーザーのお気に入りリストを取得
    list_question = list.list_questions.new(question: @question)

    if list_question.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: @question, notice: "お気に入りに追加しました！" }
      end
    else
      redirect_back fallback_location: @question, alert: "すでに登録されています。"
    end
  end

  # モーダルからのリスト更新（登録／削除まとめて）
  def update_multiple
    selected_list_ids = params[:list_ids]&.map(&:to_i) || []

    current_user.lists.each do |list|
      if selected_list_ids.include?(list.id)
        # チェックされている場合は登録
        list.list_questions.find_or_create_by(question_id: @question.id)
      else
        # チェックが外されている場合は削除
        list.list_questions.where(question_id: @question.id).destroy_all
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back fallback_location: @question, notice: "登録リストを更新しました！" }
    end
  end

  def destroy
    # current_userの全リストから対象の問題を削除
    deleted_count = ListQuestion.where(
      list_id: current_user.lists.pluck(:id),
      question_id: @question.id
    ).destroy_all.count

    if deleted_count > 0
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: @question, notice: "全てのリスト登録を解除しました。" }
      end
    else
      redirect_back fallback_location: @question, alert: "登録されているリストがありませんでした。"
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
