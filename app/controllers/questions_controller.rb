class QuestionsController < ApplicationController
  def index
    @questions = Question.includes(:user)
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      # ステップ2（CardSet追加）にリダイレクト
      redirect_to new_question_card_set_path(@question), 
                  notice: 'ステップ1完了！カードセットを追加してください（2組以上）'
    else
      flash.now[:danger] = t("defaults.flash_message.not_created", item: Question.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @question = Question.find(params[:id])
  end

  private

  def question_params
    params.require(:question).permit(:title, :description)
  end
end