class GamesController < ApplicationController
  def show
    @question = Question.find(params[:id])
    @game_data = @question.grouped_game_cards

    # セッションでゲーム状態管理
    session[:game_question_id] = @question.id
    session[:correct_matches] = 0
    session[:game_start_time] = Time.current
  end

  def check_match
    question = Question.find(session[:game_question_id])
    origin_set_id = params[:origin_set_id]
    related_word = params[:related_word]

    card_set = question.card_sets.find(origin_set_id)
    is_correct = card_set.includes_related_word?(related_word)

    if is_correct
      session[:correct_matches] = (session[:correct_matches] || 0) + 1
    end

    render json: {
      correct: is_correct,
      total_matches: session[:correct_matches],
      message: is_correct ? "正解！" : "不正解..."
    }
  end
end
