crumb :root do
  link "Home", root_path
end

# <% breadcrumb :projects %>

# auth
#   ログイン (devise/sessions#new, new_user_session_path)
crumb :session_new do
  link "ログイン", new_user_session_path
end

#   新規登録 (devise/registrations#new, new_user_registration_path)
crumb :user_new do
  link "アカウント登録", new_user_registration_path
end

#   パスワードリセット申請 (devise/passwords#new, new_user_password_path)
crumb :passwords_new do
  link "パスワードリセット申請", new_user_password_path
end

#   パスワードリセット (devise/passwords#edit, edit_user_password_path)
# <% breadcrumb :passwords_edit %>
# crumb :passwords_edit do |password|
#   link "パスワードリセット", edit_user_password_path(user_password)
#   parent :root
# end

# user
#   マイページ (users#mypage, mypage_user_path)
crumb :mypage do
  link "マイページ", mypage_user_path
end

# question
#   問題一覧 (questions#index, questions_path)
crumb :questions_index do
  link "問題一覧", questions_path
end
#   問題作成 (questions#new, new_question_path)
crumb :questions_new do
  link "問題作成", new_question_path
end
#   問題詳細 (questions#show, question_path)
crumb :questions_show do |question|
  link "#{question.title}", question_path(question)
  parent :questions_index
end

#   問題編集 (questions#edit, edit_question_path)
crumb :questions_edit do |question|
  link "問題情報を編集", edit_question_path(question)
  parent :questions_show, question
end
#   タグ検索結果 (questions#search_tag, search_tag_path)

# card_set
#   カードセット作成 (card_sets#new, new_question_card_set_path)
crumb :card_sets_new do |question|
  link "カードセットを作成", new_question_card_set_path(question)
  parent :questions_show, question
end

crumb :card_sets_edit do |question|
  link "カードセットを編集", edit_question_card_set_path(question)
  parent :questions_show, question
end

#   関連語追加 (related_words#new, new_question_card_set_related_word_path / new_related_word_path)
crumb :related_words_new do |origin_word|
  link "【#{origin_word.origin_word}】に関連語を追加", new_question_card_set_related_word_path(origin_word)
  parent :questions_show, origin_word.question
end

# game
#   ゲーム (games#show, game_path)
crumb :games_show do |question|
  link "#{question.title}", game_path(question)
  parent :questions_index
end
#   ゲーム結果 (game_records#show, game_record_path)
crumb :game_records_show do |question|
  link "【#{question.title}】の結果", game_record_path(question)
  parent :games_show, question
end

# request
#   リクエスト一覧 (requests#index, requests_path
crumb :requests_index do
  link "修正依頼一覧", requests_path
end
#   リクエスト作成 (requests#new, new_request_path)
crumb :requests_new do
  link "修正依頼作成", new_request_path
end
#   リクエスト詳細 (requests#show, request_path)
crumb :requests_show do |request|
  link "#{request.title}", request_path(request)
  parent :requests_index
end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link "#{project.name}", project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
