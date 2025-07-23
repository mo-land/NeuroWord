class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_search

  def set_search
    # @search = Question.search(params[:q])
    @search = Question.ransack(params[:q]) # ransackメソッド推奨
    @search_questions = @search.result(distinct: true).includes(:user).order(created_at: :desc).page(params[:page])
  end
end
