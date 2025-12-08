class QuestionsController < ApplicationController
  include Filterable
  include FindQuestion

  before_action :authenticate_user!, except: %i[index show]
  before_action :set_category, only: %i[index new create edit update]
  before_action :set_user_question, only: %i[edit update destroy]

  def index
    # クッキーに設定を保存
    save_filter_understood_preference

    # ベースとなるクエリを作成
    base_query = Question.all

    # カテゴリ絞り込み
    if params[:category_id].present?
      @selected_category = Category.find(params[:category_id])
      # 選択されたカテゴリとその子孫カテゴリの問題を取得
      category_ids = @selected_category.subtree_ids
      base_query = base_query.where(category_id: category_ids)
    end

    # タグ絞り込み（新規追加）
    if params[:tag_name].present?
      @selected_tag = Tag.find_by(name: params[:tag_name])
      base_query = base_query.joins(:tags).where(tags: { name: params[:tag_name] }) if @selected_tag
    end

    # 理解済み問題の除外（ログインユーザーのみ）
    if current_user && filter_understood_enabled?
      understood_ids = GameRecord.understood_question_ids_for(current_user)
      base_query = base_query.where.not(id: understood_ids) if understood_ids.present?
    end

    # search_keywordからRansackのqパラメータを構築
    ransack_params = params[:q] || {}
    if params[:search_keyword].present?
      ransack_params[:title_or_description_or_user_name_cont] = params[:search_keyword]
    end

    # Ransack検索
    @search = base_query.ransack(ransack_params)
    @search_questions = @search.result(distinct: true)
    .with_tag_relations
    .order(created_at: :desc)
    .page(params[:page])

    # カテゴリごとの絞り込み後件数を計算（タグ・検索条件適用後）
    calculate_category_counts_with_filters
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build(question_params)
    tag_list = parse_tag_params
    apply_tags_to_question(tag_list)
    if @question.save
      @question.save_tag(tag_list)
      # ステップ2（CardSet追加）にリダイレクト
      redirect_to new_question_card_set_path(@question),
      notice: "ステップ1完了！カードセットを追加してください（2組以上）"
    else
      flash.now[:alert] = t("defaults.flash_message.not_created", item: Question.model_name.human)
      apply_tags_to_question(tag_list)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    set_question
    @card_sets = @question.origin_words
    @tag_list = Tag.all
    @question_tags = @question.tags
  end

  def edit
    @tag_list = @question.tags.pluck(:name).join(",")
  end

  def update
    tag_list = parse_tag_params
    apply_tags_to_question(tag_list)
    if @question.update(question_params)
      @question.save_tag(tag_list)
      redirect_to question_path(@question), notice: t("defaults.flash_message.updated", item: Question.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_message.not_updated", item: Question.model_name.human)
      apply_tags_to_question(tag_list)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy!
    redirect_to questions_path, notice: t("defaults.flash_message.deleted", item: Question.model_name.human), status: :see_other
  end
  
  def autocomplete
    @questions = Question.where("title like ?", "%#{params[:q]}%")
    respond_to do |format|
      format.js
    end
  end
  
  private
  
  def set_user_question
    @question = current_user.questions.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :description, :category_id)
  end

  def tag_params
    params.require(:question).permit(:name)
  end

  def set_category
    @categories = Category.roots
  end

  # Tagifyから送られてくるJSON形式のタグを処理
  def parse_tag_params
    tag_json = params[:question][:tag]
    return [] unless tag_json.present?

    begin
      parsed_tags = JSON.parse(tag_json)
      parsed_tags.is_a?(Array) ? parsed_tags.map { |tag| tag["value"] } : []
    rescue JSON::ParserError
      tag_json.split(",")
    end
  end

  # タグ情報を問題に設定
  def apply_tags_to_question(tag_list)
    @question.tag_names = tag_list.join(",")
  end

  # カテゴリごとの絞り込み後件数を計算
  def calculate_category_counts_with_filters
    # タグ・検索条件のみ適用（カテゴリは除外）
    filter_query = Question.all

    if params[:tag_name].present? && @selected_tag
      filter_query = filter_query.joins(:tags).where(tags: { name: params[:tag_name] })
    end

    if current_user && filter_understood_enabled?
      understood_ids = GameRecord.understood_question_ids_for(current_user)
      filter_query = filter_query.where.not(id: understood_ids) if understood_ids.present?
    end

    ransack_params = {}
    if params[:search_keyword].present?
      ransack_params[:title_or_description_or_user_name_cont] = params[:search_keyword]
    end

    search = filter_query.ransack(ransack_params)
    filtered_questions = search.result(distinct: true)

    # カテゴリごとの件数をハッシュに格納
    @category_counts = {}
    @categories.each do |category|
      category_with_descendants = [ category ] + category.descendants
      category_with_descendants.each do |cat|
        category_ids = cat.subtree_ids
        @category_counts[cat.id] = filtered_questions.where(category_id: category_ids).count
      end
    end

    # 全体の件数
    @total_count = filtered_questions.count
  end
end
