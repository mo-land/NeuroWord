class CreateOriginWords < ActiveRecord::Migration[7.2]
  def change
    create_table :origin_words do |t|
      t.references :question, null: false, foreign_key: true
      t.string :origin_word, null: false

      t.timestamps
    end
  end
end
