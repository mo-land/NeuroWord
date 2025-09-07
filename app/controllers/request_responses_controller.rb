class RequestResponsesController < ApplicationController
  def create
    request_response = current_user.request_responses.build(request_response_params)
    if request_response.save
      redirect_to request_path(request_response.request), notice: t("defaults.flash_message.sent", item: RequestResponse.model_name.human)
    else
      redirect_to requests_path, alert: t("defaults.flash_message.not_sent", item: RequestResponse.model_name.human)
    end
  end

  private

  def request_response_params
    params.require(:request_response).permit(:content, :is_completed).merge(request_id: params[:request_id])
  end
end
