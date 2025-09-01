class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def mypage
    @questions = @user.questions.includes([ :tags ]).page(params[:questions_page]).per(5)
    @game_records = @user.game_records.includes(:question).order(created_at: :desc).page(params[:game_records_page]).per(5)
    @current_tab = params[:tab] || "user_questions"
  end

  private

  def set_user
    @user = current_user
  end
end
