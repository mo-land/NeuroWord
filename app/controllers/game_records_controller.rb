class GameRecordsController < ApplicationController
  include FindQuestion

  before_action :authenticate_user!, only: %i[create]
  before_action :set_question, only: %i[create show]

  def create
    if user_signed_in?
      start_time = session[:game_start_time] || Time.current.to_f
      @game_record = GameRecord.create(
        user: current_user,
        question: @question,
        total_matches: session[:correct_matches]&.length || 0,
        accuracy: calculate_current_accuracy,
        completion_time_seconds: Time.current.to_f - start_time,
        given_up: params[:give_up] == "true" ? true : false
      )
    end

    redirect_to game_record_path(@question)
  end

  def show
    # ログインユーザーで最新のゲーム記録があれば、それを使用
    if user_signed_in?
      @latest_game_record = current_user.game_records.where(question: @question).order(:created_at).last
    end

    if @latest_game_record
      # 保存されたゲーム記録のデータを使用
      @total_matches = @latest_game_record.total_matches
      @total_clicks = session[:total_clicks] || 0
      @correct_clicks = session[:correct_clicks] || 0
      @accuracy = @latest_game_record.accuracy
      @game_duration = @latest_game_record.completion_time_seconds
    else
      # セッションからデータを取得（未ログインユーザー等）
      @total_matches = session[:correct_matches]&.length || 0
      @total_clicks = session[:total_clicks] || 0
      @correct_clicks = session[:correct_clicks] || 0
      @accuracy = @total_clicks > 0 ? (@correct_clicks.to_f / @total_clicks * 100).round(1) : 0

      # ゲーム時間計算
      start_time = session[:game_start_time] || Time.current.to_f
      @game_duration = Time.current.to_f - start_time
    end

    # 必要な組み合わせ数を計算
    @required_matches = session[:total_required_matches] || @question.card_sets.sum { |cs| cs.related_words.count }
  end

  private

  def game_record_params
    params.require(:game_record).permit(:total_matches, :accuracy, :completion_time_seconds, :given_up)
  end

  def calculate_current_accuracy
    return 0 if session[:total_clicks].to_i == 0
    (session[:correct_clicks].to_f / session[:total_clicks] * 100).round(1)
  end
end
