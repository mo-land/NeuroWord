class Category < ApplicationRecord
  has_ancestry
  has_many :questions

  def questions_count
    Question.where(category_id: subtree_ids).length
  end
end
