class BatchPlayManager
  BATCH_SESSION_KEYS = %i[
    batch_play_mode
    batch_play_question_ids
    batch_play_current_index
    batch_play_results
    batch_play_list_id
  ].freeze

  def initialize(session)
    @session = session
  end

  def active?
    @session[:batch_play_mode] == true
  end

  def includes_question?(question_id)
    question_ids.include?(question_id)
  end

  def should_clear?(question, referer)
    return false unless active?

    is_in_batch = includes_question?(question.id)
    from_mypage_lists = referer_from_mypage_lists?(referer)
    from_batch_game = referer_from_batch_game?(referer)

    !is_in_batch || (!from_mypage_lists && !from_batch_game)
  end

  def progress_info
    return nil unless active?

    current_index = @session[:batch_play_current_index] || 0
    {
      active: true,
      progress: "#{current_index + 1} / #{question_ids.length}",
      list: List.find_by(id: @session[:batch_play_list_id])
    }
  end

  def clear
    BATCH_SESSION_KEYS.each { |key| @session.delete(key) }
  end

  # 問題IDとリストIDをセッションに記録し、バッチプレイを開始する
  def start(question_ids, list_id)
    @session[:batch_play_mode] = true
    @session[:batch_play_question_ids] = question_ids
    @session[:batch_play_current_index] = 0
    @session[:batch_play_results] = []
    @session[:batch_play_list_id] = list_id
  end

  def advance
    @session[:batch_play_current_index] = (current_index || 0) + 1
  end

  def current_question_id
    question_ids[current_index]
  end

  def all_completed?
    current_index >= question_ids.length
  end

  def current_index
    @session[:batch_play_current_index] || 0
  end

  def add_result(result)
    @session[:batch_play_results] ||= []
    @session[:batch_play_results] << result
  end

  def results
    @session[:batch_play_results] || []
  end

  def list_id
    @session[:batch_play_list_id]
  end

  private

  def question_ids
    @session[:batch_play_question_ids] || []
  end

  def referer_from_mypage_lists?(referer)
    referer.to_s.include?("/mypage") && referer.to_s.include?("tab=user_lists")
  end

  def referer_from_batch_game?(referer)
    referer.to_s.include?("/games/") && active?
  end
end
