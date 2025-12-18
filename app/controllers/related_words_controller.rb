class RelatedWordsController < ApplicationController
  include QuestionAuthorizable

  before_action :authenticate_user!
  before_action :set_card_set
  before_action :authorize_question_owner!

  def new
    @related_word = RelatedWord.new
    @card_set = @origin_word
  end

  def create
    @related_word = @origin_word.related_words.build(related_word_params)

    unless @related_word.save
      @card_set = @origin_word
      flash.now[:alert] = t("defaults.flash_message.not_created", item: RelatedWord.model_name.human)
      render :new, status: :unprocessable_entity
      return
    end

    # 「関連語を追加」ボタンの場合：同じ画面に戻る
    @related_word.save
    if params[:add_more].present?
      redirect_to new_question_card_set_related_word_path(@question, @origin_word),
        notice: "関連語を保存しました。続けてさらに関連語を追加できます。"
      return
    end

    # 「このワードセットを保存」ボタンの場合：ワードセット数に応じて遷移
    if @question.origin_words.count == 1
      redirect_to new_question_card_set_path(@question), notice: "関連語を保存しました。2つ目のカードセットを作成してください。"
    else
      redirect_to question_path(@question), notice: "関連語を保存しました。"
    end
  end

  def destroy
    @related_word = @origin_word.related_words.find(params[:id])
    @related_word.destroy!
  end

  private

  def set_card_set
    @question = Question.find(params[:question_id])
    @origin_word = @question.origin_words.find(params[:card_set_id])
  end

  def related_word_params
    params.require(:related_word).permit(:related_word)
  end
end
