class CreateQuestionTags < ActiveRecord::Migration[7.2]
  def change
    create_table :question_tags do |t|
      t.references :question, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
    # 同じ組み合わせのレコードが二重に登録されないようにする
    add_index :question_tags, [ :question_id, :tag_id ], unique: true
  end
end
