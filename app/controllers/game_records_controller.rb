class GameRecordsController < ApplicationController
  before_action :authenticate_user!, only: %i[index create]

  def index
  end

  def show
    @question = Question.find(params[:id])
    @total_matches = session[:correct_matches]&.length || 0
    @required_matches = session[:total_required_matches] || @question.card_sets.sum { |cs| cs.related_words.count }

    # クリック数ベースの正答率計算
    @total_clicks = session[:total_clicks] || 0
    @correct_clicks = session[:correct_clicks] || 0
    @accuracy = @total_clicks > 0 ? (@correct_clicks.to_f / @total_clicks * 100).round(1) : 0

    # ゲーム時間計算
    start_time = session[:game_start_time] || Time.current.to_f
    @game_duration = Time.current.to_f - start_time

    # セッションクリア
    session.delete(:game_question_id)
    session.delete(:correct_matches)
    session.delete(:total_required_matches)
    session.delete(:game_start_time)
    session.delete(:selected_origin_id)
    session.delete(:total_clicks)
    session.delete(:correct_clicks)
  end
end