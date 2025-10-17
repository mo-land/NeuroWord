class AddCategoryIdToQuestions < ActiveRecord::Migration[7.2]
  def change
    add_reference :questions, :category, null: true, foreign_key: true

    # 既存の全問題のカテゴリを「息抜き系・未分類」（category_id = 8）に設定
    reversible do |dir|
      dir.up do
        Question.update_all(category_id: 8)
      end
    end

    # null制約を追加
    change_column_null :questions, :category_id, false
  end
end
