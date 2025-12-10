module CalculateCurrentAccuracy
  extend ActiveSupport::Concern

  private

  def calculate_current_accuracy
    return 0 if session[:total_clicks].to_i == 0
    (session[:correct_clicks].to_f / session[:total_clicks] * 100).round(1)
  end
end
