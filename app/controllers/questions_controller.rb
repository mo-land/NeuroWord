class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show, :search_tag ]

  def index
    @tag_list = Tag.all
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build(question_params)
    tag_list = params[:question][:tag].split(",")
    if @question.save
      @question.save_tag(tag_list)
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
    @question_tags = @question.tags
  end

  def edit
    @question = current_user.questions.find(params[:id])
    @tag_list = @question.tags.pluck(:name).join(",")
  end

  def update
  @question = current_user.questions.find(params[:id])
  tag_list = params[:question][:tag].split(",")
    if @question.update(question_params)
      @question.save_tag(tag_list)
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

  def search_tag
    @tag_list = Tag.all
    # パラメータ名を明示的に指定
    @tag = Tag.find_by(name: params[:tags_name])
    if @tag
      @questions = @tag.questions.includes(:user, :tags).order(created_at: :desc).page(params[:page])
    else
      @questions = Question.none
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :description)
  end

  def tag_params
    params.require(:question).permit(:name)
  end
end
