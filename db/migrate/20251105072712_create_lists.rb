class CreateLists < ActiveRecord::Migration[7.2]
  def change
    create_table :lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :is_favorite, null: false, default: false

      t.timestamps
    end
    # 各ユーザーにお気に入りリストが1つまで
    add_index :lists, [:user_id], unique: true, where: "is_favorite = true", name: "index_unique_favorite_per_user"
  end
end
