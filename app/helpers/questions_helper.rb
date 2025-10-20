module QuestionsHelper
  def category_options_for_select(categories, selected_id = nil)
    options = []

    categories.each do |category|
      build_category_options(category, options)
    end

    options_for_select(options, selected_id)
  end

  private

  def build_category_options(category, options)
    # 子を持つカテゴリは選択不可（disabledオプション付き）
    if category.children.exists?
      options << [ category.name, category.id, { disabled: true } ]
      category.children.each { |child| build_category_options(child, options) }
      return
    end

    # 末端カテゴリは選択可能
    name = category.has_parent? ? "　#{category.name}" : category.name
    options << [ name, category.id ]
  end
end
