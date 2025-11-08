class List < ApplicationRecord
  belongs_to :user
  has_many :list_questions, dependent: :destroy
  has_many :questions, through: :list_questions

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 65_535 }
  validates :is_favorite, inclusion: { in: [ true, false ] }

  # 各ユーザーにお気に入りリストは1つまで
  validate :only_one_favorite_per_user

  private

  def only_one_favorite_per_user
    return unless is_favorite && user.lists.where(is_favorite: true).where.not(id: id).exists?

    errors.add(:is_favorite, "リストは1つしか作成できません")
  end
end
