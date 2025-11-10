class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def mypage
    @questions = @user.questions.includes(:category).page(params[:questions_page])
    @game_records = @user.game_records.includes(:question).order(created_at: :desc).page(params[:game_records_page]).per(10)

    # ユーザーの全リストを取得（お気に入りと通常リストを分けて結合）
    favorite_lists = @user.lists.where(is_favorite: true)
    normal_lists = @user.lists.where(is_favorite: false).order(updated_at: :desc)
    @lists = favorite_lists + normal_lists

    # 選択されたリスト（デフォルトはお気に入り）
    @selected_list_id = params[:list_id] || @user.favorite_list.id
    @list = @lists.find { |list| list.id == @selected_list_id.to_i } || @user.favorite_list

    # リストの問題をリスト追加降順で取得
    @list_questions = @list.questions
                           .order("list_questions.created_at DESC")

    @current_tab = params[:tab] || "user_questions"
  end

  private

  def set_user
    @user = current_user
  end
end
