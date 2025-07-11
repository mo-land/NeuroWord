class CreateQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :questions do |t|
      t.string :title, null: false
      t.text :description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
