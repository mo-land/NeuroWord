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
      redirect_to questions_path, success: t("defaults.flash_message.created", item: Question.model_name.human)
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
