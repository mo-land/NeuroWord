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

  # games#showへのOGP画像を動的に設定するメソッド
  def set_dynamic_ogp_image
    pattern = /[\p{Emoji}\p{Emoji_Component}&&[:^ascii:]]/
    escaped_title = @question.title.gsub(pattern, "")

    case params[:from]
    when "creator"
      # 作成者からのシェア（questions/show からのリンク）
      @url = "https://res.cloudinary.com/dyafcag5y/image/upload/l_text:TakaoPGothic_60_bold:～#{escaped_title}～%0Aの問題を作ったよ！,co_rgb:FFF,w_900,c_fit/v1752074827/kjwmtl03doe8m0ywkvvh.png"
    when "result"
      # ゲーム結果からのシェア（result.html.erb からのリンク）
      @url = "https://res.cloudinary.com/dyafcag5y/image/upload/l_text:TakaoPGothic_60_bold:～#{escaped_title}～%0Aに挑戦したよ！,co_rgb:421,w_900,c_fit/v1752074826/h0rhydkkhqhzlqvt1rbk.png"
    else
      # デフォルト（直接アクセスやその他）
      @url = "https://res.cloudinary.com/dyafcag5y/image/upload/v1752075435/iyj9hdmhh8r4njmyrwwr.png"
    end

    set_meta_tags(og: { image: @url }, twitter: { image: @url })
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
    selected_origin_id = params[:origin_set_id]&.to_i
    related_word = params[:related_word]
    clicked_set_id = params[:clicked_set_id].to_i
    current_state = params[:current_state]

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
    origin_word = @question.origin_words.find(selected_origin_id)
    is_correct = origin_word.related_words.pluck(:related_word).include?(related_word)
    is_valid_match = (clicked_set_id == selected_origin_id)

    if is_correct && is_valid_match
      # 正解の場合
      game_state.add_correct_match(selected_origin_id, related_word)
      game_state.increment_correct_clicks
      game_completed = game_state.game_completed?

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

  def session_delete
    game_state.clear_game_state
  end

  def new_game_start?
    game_state.new_game?(@question.id)
  end
end
