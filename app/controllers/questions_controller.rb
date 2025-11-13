class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show search_tag ]
  before_action :set_category, only: %i[index new create edit update]

  def index
    # ベースとなるクエリを作成
    base_query = Question.all

    # カテゴリ絞り込み
    if params[:category_id].present?
      @selected_category = Category.find(params[:category_id])
      # 選択されたカテゴリとその子孫カテゴリの問題を取得
      category_ids = @selected_category.subtree_ids
      base_query = base_query.where(category_id: category_ids)
    end

    # 理解済み問題の除外（ログインユーザーのみ）
    if current_user && params[:filter_understood] == '1'
      understood_ids = GameRecord.understood_question_ids_for(current_user)
      base_query = base_query.where.not(id: understood_ids) if understood_ids.present?
    end

    # Ransack検索
    @search = base_query.ransack(params[:q])
    @search_questions = @search.result(distinct: true)
    .includes(:user, :category)
    .order(created_at: :desc)
    .page(params[:page])
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
    @question = Question.includes(origin_words: :related_words).find(params[:id])
    @card_sets = @question.origin_words
    @tag_list = Tag.all
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
      @questions = @tag.questions.includes(:user, :category).order(created_at: :desc).page(params[:page])
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
    params.require(:question).permit(:title, :description, :category_id)
  end

  def tag_params
    params.require(:question).permit(:name)
  end

  def set_category
    @categories = Category.roots
  end
end
