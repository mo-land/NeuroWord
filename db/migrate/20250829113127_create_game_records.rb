class CreateGameRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :game_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :total_matches, null: false, default: 0
      t.float :accuracy, default: 0.0
      t.float :completion_time_seconds
      t.boolean :given_up, null: false, default: false

      t.timestamps
    end
    add_index :game_records, :accuracy
    add_index :game_records, :completion_time_seconds
    add_index :game_records, :created_at
  end
end
