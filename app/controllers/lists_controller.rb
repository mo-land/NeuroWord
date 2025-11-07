class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: %i[edit update]

  # 以下、検証のみで使用（）
  # before_action :set_list, only: %i[show edit update]

  # def index
  #   @lists = current_user.lists
  # end

  # def show
  #   @questions = @list.questions.includes(:user)
  # end

  def new
    @list = current_user.lists.new
  end

  def create
    @list = current_user.lists.new(list_params)
    if @list.save
      redirect_to mypage_user_path(tab: 'user_lists', list_id: @list.id), notice: "リストを作成しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to mypage_user_path(tab: 'user_lists', list_id: @list.id), notice: "リスト名を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_list
    @list = current_user.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
