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

    # カード上限チェック
    unless @question.can_add_card_set?
      redirect_to @question, alert: "カード数が上限に達しています"
      nil
    end
  end

  def create
    @card_set = CardForm.new(card_set_params)
    origin_word_record = @card_set.save

     unless origin_word_record
      flash.now[:alert] = "カードセットの作成に失敗しました"
      render :new, status: :unprocessable_entity
      return
    end

    if params[:add_more].present?
      redirect_to new_question_card_set_related_word_path(@question, origin_word_record.id),
        notice: "カードセットを作成しました。続けて関連語を追加できます。"
      return
    end

    if @question.origin_words.count == 1
      redirect_to new_question_card_set_path(@question),
        notice: "最初のカードセットを作成しました。続けて2つ目のカードセットも作成しましょう！"
    else
      redirect_to question_path(@question),
        notice: "カードセットを作成しました"
    end
  end

  # GET /questions/:question_id/card_sets/:id/edit
  def edit
    @card_set = @question.origin_words.find(params[:id])
  end

  def update
    unless @card_set.update(update_params)
      flash.now[:alert] = "カードセットの更新に失敗しました"
      render :edit, status: :unprocessable_entity
      return
    end
    
    # 関連語の更新
    if params[:origin_word][:related_words].present?
      unless update_related_words
        flash.now[:alert] = "関連語の更新に失敗しました"
        render :edit, status: :unprocessable_entity
        return
      end
    end

    # リダイレクト先の決定
    if params[:add_more].present?
      redirect_to new_question_card_set_related_word_path(@question, @card_set),
      notice: "カードセットを更新しました。続けて関連語を追加できます。"
    elsif @question.origin_words.count == 1
      redirect_to new_question_card_set_path(@question),
      notice: "カードセットを更新しました。続けて2つ目のカードセットも作成しましょう！"
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
    success = true

    permitted_related_words[:related_words]&.each do |id, rw_params|
      related_word = @card_set.related_words.find_by(id: id)
      next unless related_word

      unless related_word.update(related_word: rw_params[:related_word])
        # エラーを親の@card_setに転記
        related_word.errors.full_messages.each do |message|
          @card_set.errors.add(:base, message)
        end
        success = false
      end
    end

    success
  end
end
