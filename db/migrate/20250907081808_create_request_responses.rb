class CreateRequestResponses < ActiveRecord::Migration[7.2]
  def change
    create_table :request_responses do |t|
      t.references :request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.boolean :is_completed

      t.timestamps
    end
  end
end
