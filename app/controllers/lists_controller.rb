class ListsController < ApplicationController
  include Filterable

  before_action :authenticate_user!
  before_action :set_list, only: %i[edit update batch_play destroy]

  def new
    @list = current_user.lists.new
    @current_list_id = params[:list_id]
  end

  def create
    @list = current_user.lists.new(list_params)
    if @list.save
      redirect_to mypage_user_path(tab: "user_lists", list_id: @list.id), notice: "リストを作成しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to mypage_user_path(tab: "user_lists", list_id: @list.id), notice: "リストを更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy!
    redirect_to mypage_user_path(tab: "user_lists"), notice: t("defaults.flash_message.deleted", item: List.model_name.human), status: :see_other
  end

  def batch_play
    # リストの問題を取得（フィルタリング適用）
    questions = @list.questions.order("list_questions.created_at DESC")

    # 理解済み問題のフィルタリング
    if filter_understood_enabled?
      understood_ids = GameRecord.understood_question_ids_for(current_user)
      questions = questions.where.not(id: understood_ids) if understood_ids.present?
    end

    # ゲーム可能な問題のみに絞り込み
    valid_questions = questions.select { |q| q.valid_for_game? }

    if valid_questions.empty?
      redirect_to mypage_user_path(tab: "user_lists", list_id: @list.id), alert: "プレイ可能な問題がありません"
      return
    end

    # 問題をランダムにシャッフル
    shuffled_question_ids = valid_questions.map(&:id).shuffle

    # セッションに保存
    session[:batch_play_mode] = true
    session[:batch_play_question_ids] = shuffled_question_ids
    session[:batch_play_current_index] = 0
    session[:batch_play_results] = []
    session[:batch_play_list_id] = @list.id

    # 最初のゲームへリダイレクト
    redirect_to game_path(shuffled_question_ids.first)
  end

  private

  def set_list
    @list = current_user.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
