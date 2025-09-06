class RequestsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index ]

  def index
    @search_request = Request.ransack(params[:q]) # ransackメソッド推奨
    @search_requests = @search_request.result(distinct: true).includes(:user, :question, { question: :user }).order(created_at: :desc).page(params[:page])
    @current_requests_tab = params[:tab] || "requests"
  end

  def new
    @request = Request.new
    @search = Question.ransack(params[:q])
  end

  def create
    @request = current_user.requests.build(request_params)
    if @request.save
      redirect_to request_path(@request), success: t("defaults.flash_message.created", item: Request.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_created", item: Request.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @request = Request.find(params[:id])
  end

  private

  def request_params
    params.require(:request).permit(:title, :content, :question_id)
  end
end
