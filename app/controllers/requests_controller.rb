class RequestsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index ]

  def index
    @current_requests_tab = params[:tab] || "requests"
  end

  def new
    @request = Request.new
  end
end
