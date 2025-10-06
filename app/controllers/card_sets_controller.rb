# app/controllers/card_sets_controller.rb
class CardSetsController < ApplicationController
  include QuestionAuthorizable

  before_action :authenticate_user!
  before_action :set_question
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
  end

   # PATCH/PUT /questions/:question_id/card_sets/:id
   # def update
   #   if @card_set.update(card_set_params)
   #     @question.touch

   #     respond_to do |format|
   #       format.html { redirect_to @question, notice: "カードセットを更新しました" }
   #       format.turbo_stream {
   #         render turbo_stream: [
   #           turbo_stream.replace(@card_set, partial: "card_sets/card_set", locals: { card_set: @card_set, question: @question }),
   #           turbo_stream.update("card_limit_info", partial: "card_sets/card_limit_info", locals: { question: @question }),
   #           turbo_stream.update("flash_messages", html: %(<div class="alert alert-success shadow-lg my-2"><span>カードセットを更新しました</span></div>).html_safe)
   #         ]
   #       }
   #     end
   #   else
   #     respond_to do |format|
   #       format.html { render :edit, status: :unprocessable_entity }
   #       format.turbo_stream {
   #         render turbo_stream: turbo_stream.update("edit_card_set_#{@card_set.id}", partial: "card_sets/form", locals: { card_set: @card_set, question: @question })
   #       }
   #     end
   #   end
   # end

   def destroy
    @card_set = @question.origin_words.find(params[:id])
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

  def card_set_params
    params.require(:card_form).permit(:origin_word, :related_word).merge(question_id: @question.id)
  end
end
