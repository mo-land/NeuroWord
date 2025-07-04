class GamesController < ApplicationController
  before_action :set_question, only: [ :show, :check_match, :result ]

  # GET /games/:id (questionのIDを使用)
  def show
    unless @question.valid_for_game?
      redirect_to @question, alert: "ゲームを開始するには2組以上のカードセットが必要です"
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
    click_type = params[:click_type] # 'origin' or 'related'

    # すべてのクリックをカウント
    session[:total_clicks] = (session[:total_clicks] || 0) + 1

    if click_type == "origin"
      handle_origin_click
    elsif click_type == "related"
      handle_related_click
    else
      render json: { error: "Invalid click type" }, status: 400
    end
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

  def handle_origin_click
    origin_set_id = params[:origin_set_id].to_i
    current_state = params[:current_state]
    is_completed = params[:is_completed]

    # 既に完了している起点カードかチェック
    if is_completed
      render json: {
        valid_action: false,
        message: "この起点カードは既に完了しています",
        total_clicks: session[:total_clicks],
        correct_clicks: session[:correct_clicks],
        current_accuracy: calculate_current_accuracy
      }
      return
    end

    # 起点カード選択は基本的に常に有効（ゲーム状態関係なく）
    session[:correct_clicks] = (session[:correct_clicks] || 0) + 1

    render json: {
      valid_action: true,
      message: "起点カードを選択しました。関連語を選んでください！",
      total_clicks: session[:total_clicks],
      correct_clicks: session[:correct_clicks],
      current_accuracy: calculate_current_accuracy
    }
  end

  def handle_related_click
    selected_origin_id = params[:origin_set_id]&.to_i
    related_word = params[:related_word]
    clicked_set_id = params[:clicked_set_id].to_i
    current_state = params[:current_state]
    is_already_selected = params[:is_already_selected]

    # 既に選択済みのカードをクリックした場合
    if is_already_selected
      render json: {
        valid_action: false,
        correct: false,
        message: "このカードは既に選択済みです",
        total_clicks: session[:total_clicks],
        correct_clicks: session[:correct_clicks],
        current_accuracy: calculate_current_accuracy
      }
      return
    end

    # 起点カードが選択されていない場合
    if selected_origin_id.nil? || current_state != "SELECT_RELATED"
      render json: {
        valid_action: false,
        correct: false,
        message: "まず起点カードを選択してください",
        total_clicks: session[:total_clicks],
        correct_clicks: session[:correct_clicks],
        current_accuracy: calculate_current_accuracy
      }
      return
    end

    # マッチング判定
    card_set = @question.card_sets.find(selected_origin_id)
    is_correct = card_set.includes_related_word?(related_word)
    is_valid_match = (clicked_set_id == selected_origin_id)

    if is_correct && is_valid_match && !session[:correct_matches].include?("#{selected_origin_id}-#{related_word}")
      # 正解の場合
      session[:correct_matches] << "#{selected_origin_id}-#{related_word}"
      session[:correct_clicks] = (session[:correct_clicks] || 0) + 1

      # ゲーム完了チェック
      game_completed = session[:correct_matches].length == session[:total_required_matches]

      render json: {
        valid_action: true,
        correct: true,
        total_matches: session[:correct_matches].length,
        required_matches: session[:total_required_matches],
        game_completed: game_completed,
        total_clicks: session[:total_clicks],
        correct_clicks: session[:correct_clicks],
        current_accuracy: calculate_current_accuracy,
        message: "正解！"
      }
    else
      # 不正解の場合
      message = if !is_valid_match
                  "選択したカードは、現在の起点カードとセットになっていません"
      else
                  "不正解..."
      end

      render json: {
        valid_action: true,
        correct: false,
        message: message,
        total_clicks: session[:total_clicks],
        correct_clicks: session[:correct_clicks],
        current_accuracy: calculate_current_accuracy
      }
    end
  end

  def calculate_current_accuracy
    return 0 if session[:total_clicks].to_i == 0
    (session[:correct_clicks].to_f / session[:total_clicks] * 100).round(1)
  end
end
