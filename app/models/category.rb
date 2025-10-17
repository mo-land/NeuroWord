class Category < ApplicationRecord
  has_ancestry
  has_many :questions
end
