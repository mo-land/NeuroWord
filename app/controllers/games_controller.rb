class GamesController < ApplicationController
  before_action :set_question, only: [:show, :check_match, :result]

  # GET /games/:id (questionのIDを使用)
  def show
    unless @question.valid_for_game?
      redirect_to @question, alert: 'ゲームを開始するには2組以上のカードセットが必要です'
      return
    end

    @game_data = @question.grouped_game_cards

    # セッションでゲーム状態管理
    session[:game_question_id] = @question.id
    session[:correct_matches] = []
    session[:total_required_matches] = @game_data[:relateds].count
    session[:game_start_time] = Time.current.to_f
    session[:selected_origin_id] = nil
    # クリック数追跡用
    session[:total_clicks] = 0
    session[:correct_clicks] = 0
  end

  # POST /games/:id/check_match
  def check_match
    origin_set_id = params[:origin_set_id].to_i
    related_word = params[:related_word]

    # クリック数をカウント
    session[:total_clicks] = (session[:total_clicks] || 0) + 1

    card_set = @question.card_sets.find(origin_set_id)
    is_correct = card_set.includes_related_word?(related_word)

    if is_correct && !session[:correct_matches].include?("#{origin_set_id}-#{related_word}")
      session[:correct_matches] << "#{origin_set_id}-#{related_word}"
      # 正解クリック数をカウント
      session[:correct_clicks] = (session[:correct_clicks] || 0) + 1
    end

    # ゲーム完了チェック
    game_completed = session[:correct_matches].length == session[:total_required_matches]

    # 現在の正答率を計算
    current_accuracy = session[:total_clicks] > 0 ? 
      (session[:correct_clicks].to_f / session[:total_clicks] * 100).round(1) : 0

    render json: {
      correct: is_correct,
      total_matches: session[:correct_matches].length,
      required_matches: session[:total_required_matches],
      game_completed: game_completed,
      total_clicks: session[:total_clicks],
      correct_clicks: session[:correct_clicks],
      current_accuracy: current_accuracy,
      message: is_correct ? "正解！" : "不正解..."
    }
  end

  # GET /games/:id/result
  def result
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

  private

  def set_question
    @question = Question.find(params[:id])
  end
end