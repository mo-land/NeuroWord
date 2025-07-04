class QuestionsController < ApplicationController
  def index
    @questions = Question.includes(:user).order(created_at: :desc)
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build(question_params)
    if @question.save
      # ステップ2（CardSet追加）にリダイレクト
      redirect_to new_question_card_set_path(@question),
                  notice: "ステップ1完了！カードセットを追加してください（2組以上）"
    else
      flash.now[:danger] = t("defaults.flash_message.not_created", item: Question.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @question = Question.find(params[:id])
  end

  def edit
    @question = current_user.questions.find(params[:id])
  end

  def update
  @question = current_user.questions.find(params[:id])
    if @question.update(question_params)
      redirect_to question_path(@question), success: t("defaults.flash_message.updated", item: Question.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_updated", item: Question.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  question = current_user.questions.find(params[:id])
    question.destroy!
    redirect_to questions_path, success: t("defaults.flash_message.deleted", item: Question.model_name.human), status: :see_other
  end

  private

  def question_params
    params.require(:question).permit(:title, :description)
  end
end
