# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

fe, rails, js, css, git, it, others, breath_or_uncategorized  = Category.create([
  {name: '基本情報'},
  {name: 'Ruby on Rails'},
  {name: 'JavaScript'},
  {name: 'CSS'},
  {name: 'Git'},
  {name: 'その他学習（IT系）'},
  {name: 'その他学習（IT以外）'},
  {name: '息抜き系・未分類'}
  ])


technology, management, strategy = fe.children.create(
  [
    { name: 'テクノロジ系' },
    { name: 'マネジメント系' },
    { name: 'ストラテジ系' },
  ]
)

['基礎理論', 'コンピュータシステム', '技術要素_データベース', '技術要素_ネットワーク', '技術要素_セキュリティ', '技術要素_その他', '開発技術'].each do |name|
  technology.children.create(name: name)
end

['プロジェクトマネジメント', 'サービスマネジメント'].each do |name|
  management.children.create(name: name)
end

['システム戦略', '経営戦略', '企業と法務'].each do |name|
  strategy.children.create(name: name)
end

# -------------------------------

# 10.times do
#   User.create!(name: Faker::Name.name,
#   email: Faker::Internet.unique.email,
#   password: "password",
#   password_confirmation: "password")
# end

# user_ids = User.ids

# 20.times do |index|
#   user = User.find(user_ids.sample)
#   user.questions.create!(title: "タイトル#{index}", description: "本文#{index}")
# end

# -------------------------------