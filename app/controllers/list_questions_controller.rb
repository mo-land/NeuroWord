class ListQuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question
  before_action :set_context, only: %i[create update_multiple destroy]
  before_action :set_list_questions, only: %i[update_multiple destroy]
  before_action :set_game_records, only: %i[create update_multiple destroy]

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
  
  def set_context
    @context = params[:context]
  end
  
  def set_list_questions
    if params[:list_id].present?
      @list = current_user.lists.find(params[:list_id])
      @list_questions = @list.questions.order("list_questions.created_at DESC")
    end
  end
  
  def set_game_records
    # game_recordsの場合、該当する全てのgame_recordを取得
    if @context == "game_records"
      @game_records = current_user.game_records.where(question_id: @question.id)
    end
  end
end
