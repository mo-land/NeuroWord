class CreateListQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :list_questions do |t|
      t.references :list, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end

    # 同一リスト内で同じ問題を重複登録させない
    add_index :list_questions, [:list_id, :question_id], unique: true
  end
end
