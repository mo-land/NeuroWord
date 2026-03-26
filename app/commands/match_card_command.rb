# 起点カード選択済み（SELECT_RELATED状態）かつ正しいセットへの回答かを検証する。
class MatchCardCommand
  Result = Struct.new(:valid_action, :correct, :message, :game_completed, keyword_init: true)

  def initialize(question:, game_state:, params:)
    @question           = question
    @game_state         = game_state
    @selected_origin_id = params[:origin_set_id]&.to_i
    @related_word       = params[:related_word]
    @clicked_set_id     = params[:clicked_set_id].to_i
    @current_state      = params[:current_state]
  end

  def call
    return invalid_state_result unless valid_state?

    if correct_match?
      @game_state.add_correct_match(@selected_origin_id, @related_word)
      @game_state.increment_correct_clicks
      Result.new(valid_action: true, correct: true, message: "正解！", game_completed: @game_state.game_completed?)
    else
      Result.new(valid_action: true, correct: false, message: error_message, game_completed: false)
    end
  end

  private

  def valid_state?
    # SELECT_RELATED: 起点カード選択後、関連語カードの選択を待つ状態
    @selected_origin_id.present? && @current_state == "SELECT_RELATED"
  end

  def correct_match?
    # clicked_set_idが一致しない場合、関連語が正しくても別セットへの誤操作となるため両条件が必要
    origin_word.related_words.pluck(:related_word).include?(@related_word) &&
      @clicked_set_id == @selected_origin_id
  end

  def origin_word
    @origin_word ||= @question.origin_words.find(@selected_origin_id)
  end

  def error_message
    if @clicked_set_id != @selected_origin_id
      "選択したカードは、現在の起点カードとセットになっていません"
    else
      "不正解..."
    end
  end

  def invalid_state_result
    Result.new(valid_action: false, correct: false, message: "まず起点カードを選択してください", game_completed: false)
  end
end
