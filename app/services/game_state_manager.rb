class GameStateManager
  GAME_SESSION_KEYS = %i[
    game_question_id
    correct_matches
    total_required_matches
    game_start_time
    selected_origin_id
    total_clicks
    correct_clicks
  ].freeze

  def initialize(session)
    @session = session
  end

  def initialize_game(question, game_data)
    @session[:game_question_id] = question.id
    @session[:correct_matches] = []
    @session[:total_required_matches] = game_data[:relateds].count
    @session[:game_start_time] = Time.current.to_f
    @session[:selected_origin_id] = nil
    @session[:total_clicks] = 0
    @session[:correct_clicks] = 0
  end

  def clear_game_state
    GAME_SESSION_KEYS.each { |key| @session.delete(key) }
  end

  def increment_total_clicks
    @session[:total_clicks] = (@session[:total_clicks] || 0) + 1
  end

  def increment_correct_clicks
    @session[:correct_clicks] = (@session[:correct_clicks] || 0) + 1
  end

  def add_correct_match(origin_id, related_word)
    @session[:correct_matches] ||= []
    match_key = "#{origin_id}-#{related_word}"
    @session[:correct_matches] << match_key unless @session[:correct_matches].include?(match_key)
  end

  def game_completed?
    (@session[:correct_matches] || []).length >= (@session[:total_required_matches] || 0)
  end

  def stats
    {
      total_clicks: @session[:total_clicks] || 0,
      correct_clicks: @session[:correct_clicks] || 0,
      correct_matches: (@session[:correct_matches] || []).length,
      required_matches: @session[:total_required_matches] || 0
    }
  end

  def new_game?(question_id)
    @session[:game_question_id] != question_id
  end

  def total_clicks
    @session[:total_clicks] || 0
  end

  def correct_clicks
    @session[:correct_clicks] || 0
  end

  def correct_matches_count
    (@session[:correct_matches] || []).length
  end

  def total_required_matches
    @session[:total_required_matches] || 0
  end

  def start_time
    @session[:game_start_time] || Time.current.to_f
  end
end
