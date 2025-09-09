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
    # Tagifyから送られてくるJSON形式のタグを処理
    tag_json = params[:question][:tag]
    tag_list = []
    if tag_json.present?
      begin
        parsed_tags = JSON.parse(tag_json)
        tag_list = parsed_tags.map { |tag| tag["value"] } if parsed_tags.is_a?(Array)
      rescue JSON::ParserError
        # JSON形式でない場合はカンマ区切りとして処理
        tag_list = tag_json.split(",")
      end
    end
    @question.tag_names = tag_list.join(",")
    if @question.save
      @question.save_tag(tag_list)
      # ステップ2（CardSet追加）にリダイレクト
      redirect_to new_question_card_set_path(@question),
                  notice: "ステップ1完了！カードセットを追加してください（2組以上）"
    else
      flash.now[:alert] = t("defaults.flash_message.not_created", item: Question.model_name.human)
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
    # Tagifyから送られてくるJSON形式のタグを処理
    tag_json = params[:question][:tag]
    tag_list = []
    if tag_json.present?
      begin
        parsed_tags = JSON.parse(tag_json)
        tag_list = parsed_tags.map { |tag| tag["value"] } if parsed_tags.is_a?(Array)
      rescue JSON::ParserError
        # JSON形式でない場合はカンマ区切りとして処理
        tag_list = tag_json.split(",")
      end
    end
    @question.tag_names = tag_list.join(",")
    if @question.update(question_params)
      @question.save_tag(tag_list)
      redirect_to question_path(@question), notice: t("defaults.flash_message.updated", item: Question.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_message.not_updated", item: Question.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  question = current_user.questions.find(params[:id])
    question.destroy!
    redirect_to questions_path, notice: t("defaults.flash_message.deleted", item: Question.model_name.human), status: :see_other
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

  def autocomplete
    @questions = Question.where("title like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.js
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
