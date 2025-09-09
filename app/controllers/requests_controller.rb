class RequestsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index show ]

  def index
    # 検索条件がない場合はデフォルトで未完了のみ表示
    search_params = params[:q] || {}

    # 初回アクセス（検索条件が空）の場合は未完了のみ表示
    if search_params.empty?
      search_params[:status_in] = [ "0" ]
    end

    @search_request = Request.ransack(search_params) # ransackメソッド推奨
    @search_requests = @search_request.result(distinct: true).includes(:user, :question, { question: :user }, { request_responses: :user }).order(created_at: :desc).page(params[:page])
    @current_requests_tab = params[:tab] || "requests"
  end

  def new
    @request = Request.new
    @search = Question.ransack(params[:q])
  end

  def create
    @request = current_user.requests.build(request_params)
    if @request.save
      redirect_to request_path(@request), notice: t("defaults.flash_message.created", item: Request.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_message.not_created", item: Request.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @request = Request.find(params[:id])
    @request_response = RequestResponse.new
    @request_responses = @request.request_responses.includes(:user).order(created_at: :asc)
    @latest_request_response = @request_responses.last
  end

  private

  def request_params
    params.require(:request).permit(:title, :content, :question_id)
  end
end
