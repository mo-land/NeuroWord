class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def mypage
    @questions = @user.questions.includes([ :tags ]).page(params[:page])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def set_user
    @user = current_user
  end
end
