class RequestResponsesController < ApplicationController
  def create
    @request = Request.find(params[:request_id])
    @request_response = current_user.request_responses.build(request_response_params)
    @request_responses = @request.request_responses.includes(:user).order(created_at: :asc)
    @latest_request_response = @request_responses.last
    
    if @request_response.save
      redirect_to request_path(@request), notice: t("defaults.flash_message.sent", item: RequestResponse.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_message.not_sent", item: RequestResponse.model_name.human)
      render 'requests/show', status: :unprocessable_entity
    end
  end

  private

  def request_response_params
    params.require(:request_response).permit(:content, :is_completed).merge(request_id: params[:request_id])
  end
end
