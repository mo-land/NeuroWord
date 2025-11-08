class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: %i[edit update]

  def new
    @list = current_user.lists.new
  end

  def create
    @list = current_user.lists.new(list_params)
    if @list.save
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "リストを作成しました！"
          render turbo_stream: turbo_stream.update("flash", partial: "shared/flash_messages")
        end
        format.html { redirect_to mypage_user_path(tab: 'user_lists', list_id: @list.id), notice: "リストを作成しました！" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @list.update(list_params)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "リストを更新しました！"
          @lists = current_user.lists
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash_messages"),
            turbo_stream.update("list_selector_container", partial: "users/list_selector", locals: { lists: @lists, selected_list_id: @list.id })
          ]
        end
        format.html { redirect_to mypage_user_path(tab: 'user_lists', list_id: @list.id), notice: "リストを更新しました！" }
      end
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
