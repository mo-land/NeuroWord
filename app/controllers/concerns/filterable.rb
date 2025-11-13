module Filterable
  extend ActiveSupport::Concern

  included do
    helper_method :filter_understood_enabled?
  end

  private

  # 理解済み問題フィルターの状態を取得
  def filter_understood_enabled?
    # パラメータで明示的に指定されている場合はそれを優先
    if params[:filter_understood].present?
      params[:filter_understood] == "1"
    else
      # クッキーから取得（デフォルトはfalse）
      cookies[:filter_understood] == "1"
    end
  end

  # 理解済み問題フィルターの状態を保存
  def save_filter_understood_preference
    if params[:filter_understood].present?
      cookies.permanent[:filter_understood] = params[:filter_understood]
    end
  end
end
