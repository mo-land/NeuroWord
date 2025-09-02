class RequestsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index ]

  def index
    @requests = Request.includes(:user, :question).page(params[:game_records_page]).per(5)
    @current_requests_tab = params[:tab] || "user_requests"
  end
end
