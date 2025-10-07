# app/controllers/card_sets_controller.rb
class CardSetsController < ApplicationController
  include QuestionAuthorizable

  before_action :authenticate_user!
  before_action :set_question
  before_action :set_card_set, only: %i[edit update destroy]
  before_action :authorize_question_owner!

  # GET /questions/:question_id/card_sets/new
  def new
    @card_set = CardForm.new(question_id: @question.id)
  end

  def create
    @card_set = CardForm.new(card_set_params)
    origin_word_record = @card_set.save

    if origin_word_record
      if params[:add_more].present?
        redirect_to new_question_card_set_related_word_path(@question, origin_word_record.id)
      else
        # ワードセットが1つなら新規作成画面へ、2つ以上なら問題詳細画面へ
        if @question.origin_words.count == 1
          redirect_to new_question_card_set_path(@question)
        else
          redirect_to question_path(@question)
        end
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /questions/:question_id/card_sets/:id/edit
  def edit
    @card_set = @question.origin_words.find(params[:id])
  end

  def update
    unless @card_set.update(update_params)
      render :edit, status: :unprocessable_entity
      return
    end

    # 関連語の更新
    update_related_words if params[:origin_word][:related_words].present?

    # リダイレクト先の決定
    if params[:add_more].present?
      redirect_to new_question_card_set_related_word_path(@question, @card_set)
    elsif @question.origin_words.count == 1
      redirect_to new_question_card_set_path(@question)
    else
      redirect_to question_path(@question), notice: "カードセットを更新しました"
    end
  end

  def destroy
    @card_sets = @question.origin_words
    if @card_sets.size > 2
      @card_set.destroy!
      redirect_to question_path(@question), notice: "カードセットを削除しました"
    else
      redirect_to question_path(@question), alert: "ゲーム不可となるため、カードセットを追加してから削除してください"
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def set_card_set
    @card_set = @question.origin_words.find(params[:id])
  end

  def card_set_params
    params.require(:card_form).permit(:origin_word, :related_word).merge(question_id: @question.id)
  end

  def update_params
    params.require(:origin_word).permit(:origin_word)
  end

  def update_related_words
    permitted_related_words = params.require(:origin_word).permit(related_words: [ :related_word ])
    permitted_related_words[:related_words]&.each do |id, rw_params|
      related_word = @card_set.related_words.find_by(id: id)
      related_word&.update(related_word: rw_params[:related_word])
    end
  end
end
