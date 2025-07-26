class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false

      t.timestamps
    end
    # tag_name で検索するため index を貼り 一意制約を設定
    add_index :tags, :name, unique: true
  end
end
