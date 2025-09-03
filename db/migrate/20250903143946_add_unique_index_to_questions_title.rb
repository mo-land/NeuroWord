class AddUniqueIndexToQuestionsTitle < ActiveRecord::Migration[7.2]
  def change
    add_index :questions, :title, unique: true
  end
end
