# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_09_07_081808) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "card_sets", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "origin_word", limit: 40, null: false
    t.json "related_words", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_card_sets_on_question_id"
  end

  create_table "game_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.integer "total_matches", default: 0, null: false
    t.float "accuracy", default: 0.0
    t.float "completion_time_seconds"
    t.boolean "given_up", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accuracy"], name: "index_game_records_on_accuracy"
    t.index ["completion_time_seconds"], name: "index_game_records_on_completion_time_seconds"
    t.index ["created_at"], name: "index_game_records_on_created_at"
    t.index ["question_id"], name: "index_game_records_on_question_id"
    t.index ["user_id"], name: "index_game_records_on_user_id"
  end

  create_table "question_tags", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "tag_id"], name: "index_question_tags_on_question_id_and_tag_id", unique: true
    t.index ["question_id"], name: "index_question_tags_on_question_id"
    t.index ["tag_id"], name: "index_question_tags_on_tag_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_questions_on_title", unique: true
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "request_responses", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.boolean "is_completed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_request_responses_on_request_id"
    t.index ["user_id"], name: "index_request_responses_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "content", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_requests_on_question_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "card_sets", "questions"
  add_foreign_key "game_records", "questions"
  add_foreign_key "game_records", "users"
  add_foreign_key "question_tags", "questions"
  add_foreign_key "question_tags", "tags"
  add_foreign_key "questions", "users"
  add_foreign_key "request_responses", "requests"
  add_foreign_key "request_responses", "users"
  add_foreign_key "requests", "questions"
  add_foreign_key "requests", "users"
end
