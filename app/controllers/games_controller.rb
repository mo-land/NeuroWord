class GamesController < ApplicationController
  include FindQuestion
  include CalculateCurrentAccuracy
  before_action :set_question, only: %i[show check_match ]
  before_action :session_delete, only:  %i[show], if: :new_game_start?

  # GET /games/:id (questionのIDを使用)
  def show
    unless @question.valid_for_game?
      redirect_to @question, alert: "ゲームを開始するには2組以上のカードセットが必要です"
      return
    end

    @game_data = @question.grouped_game_cards
    set_dynamic_ogp_image

    if batch_play_manager.should_clear?(@question, request.referer)
      batch_play_manager.clear
    end

    progress = batch_play_manager.progress_info
    @batch_play_mode = progress&.dig(:active) || false
    @batch_play_progress = progress&.dig(:progress)
    @batch_play_list = progress&.dig(:list)

    game_state.initialize_game(@question, @game_data)
  end

  # POST /games/:id/check_match
  def check_match
    click_type = params[:click_type] # 'origin' or 'related'

    game_state.increment_total_clicks

    if click_type == "origin"
      handle_origin_click
    elsif click_type == "related"
      handle_related_click
    else
      render json: { error: "Invalid click type" }, status: 400
    end
  end

  private

  def game_state
    @game_state ||= GameStateManager.new(session)
  end

   def batch_play_manager
    @batch_play_manager ||= BatchPlayManager.new(session)
  end

  # SNSシェア時のコンテキスト（作成者 or プレイ結果）に応じてOGP画像を切り替える。
  def set_dynamic_ogp_image
    url = OgpImagePresenter.new(@question, params[:from]).url
    set_meta_tags(og: { image: url }, twitter: { image: url })
  end

  def handle_origin_click
    origin_set_id = params[:origin_set_id].to_i
    current_state = params[:current_state]
    is_completed = params[:is_completed]

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
    game_state.increment_correct_clicks

    render json: {
      valid_action: true,
      message: "起点カードを選択しました。関連語を選んでください！",
      total_clicks: session[:total_clicks],
      correct_clicks: session[:correct_clicks],
      current_accuracy: calculate_current_accuracy
    }
  end

  def handle_related_click
    result = MatchCardCommand.new(
      question:   @question,
      game_state: game_state,
      params:     params
    ).call

    response = {
      valid_action:     result.valid_action,
      correct:          result.correct,
      message:          result.message,
      total_clicks:     session[:total_clicks],
      correct_clicks:   session[:correct_clicks],
      current_accuracy: calculate_current_accuracy
    }

    if result.correct
      response[:total_matches]    = session[:correct_matches].length
      response[:required_matches] = session[:total_required_matches]
      response[:game_completed]   = result.game_completed
    end

    render json: response
  end

  def session_delete
    game_state.clear_game_state
  end

  def new_game_start?
    game_state.new_game?(@question.id)
  end
end
