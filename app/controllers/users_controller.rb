class UsersController < ApplicationController
  include Filterable

  before_action :authenticate_user!
  before_action :set_user

  def mypage
    # クッキーに設定を保存
    save_filter_understood_preference

    @questions = @user.questions.includes(:category, :tags).page(params[:questions_page])

    # プレイ履歴のフィルタリング
    game_records_query = @user.game_records.includes(:question).order(created_at: :desc)
    if filter_understood_enabled?
      understood_ids = GameRecord.understood_question_ids_for(@user)
      game_records_query = game_records_query.where.not(question_id: understood_ids) if understood_ids.present?
    end
    @game_records = game_records_query.page(params[:game_records_page]).per(10)

    # ユーザーの全リストを取得（お気に入りと通常リストを分けて結合）
    favorite_lists = @user.lists.where(is_favorite: true)
    normal_lists = @user.lists.where(is_favorite: false).order(updated_at: :desc)
    @lists = favorite_lists + normal_lists

    # 選択されたリスト（デフォルトはお気に入り）
    @selected_list_id = params[:list_id] || @user.favorite_list.id
    @list = @lists.find { |list| list.id == @selected_list_id.to_i } || @user.favorite_list

    # リストの問題をリスト追加降順で取得（フィルタリング適用）
    list_questions_query = @list.questions.order("list_questions.created_at DESC")
    if filter_understood_enabled?
      understood_ids = GameRecord.understood_question_ids_for(@user)
      list_questions_query = list_questions_query.where.not(id: understood_ids) if understood_ids.present?
    end
    @list_questions = list_questions_query

    @current_tab = params[:tab] || "user_questions"
  end

  private

  def set_user
    @user = current_user
  end
end
