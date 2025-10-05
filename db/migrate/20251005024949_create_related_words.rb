class CreateRelatedWords < ActiveRecord::Migration[7.2]
  def change
    create_table :related_words do |t|
      t.references :origin_word, null: false, foreign_key: true
      t.string :related_word, null: false

      t.timestamps
    end
    add_index :related_words, [ :origin_word_id, :related_word ], unique: true
  end
end
