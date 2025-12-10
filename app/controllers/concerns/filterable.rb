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

  # 理解済み問題を除外したクエリを返す（Question用）
  def apply_understood_filter(relation, user)
    return relation unless filter_understood_enabled?

    understood_ids = GameRecord.understood_question_ids_for(user)
    understood_ids.present? ? relation.where.not(id: understood_ids) : relation
  end

  # 理解済み問題を除外したクエリを返す（GameRecord用）
  def apply_understood_filter_to_records(relation, user)
    return relation unless filter_understood_enabled?

    understood_ids = GameRecord.understood_question_ids_for(user)
    understood_ids.present? ? relation.where.not(question_id: understood_ids) : relation
  end
end
