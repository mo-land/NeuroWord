class CreateCardSets < ActiveRecord::Migration[7.2]
  def change
    create_table :card_sets do |t|
      t.references :question, null: false, foreign_key: true
      t.string :origin_word, null: false, limit: 40
      t.json :related_words, null: false

      t.timestamps
    end
  end
end
