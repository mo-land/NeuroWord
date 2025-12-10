module ClearBatchPlaySession
  extend ActiveSupport::Concern

  private

  def clear_batch_play_session
    session.delete(:batch_play_mode)
    session.delete(:batch_play_question_ids)
    session.delete(:batch_play_current_index)
    session.delete(:batch_play_results)
    session.delete(:batch_play_list_id)
  end
end
