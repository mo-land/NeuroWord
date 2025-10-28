require "csv"
# db/seeds/questions.csv を読み込む

namespace :import do
  desc "CSVから問題データをインポート"
  task questions: :environment do
    # 環境変数から作成者を取得
    user = User.find_by(email: ENV["IMPORT_USER_EMAIL"])
    raise "IMPORT_USER_EMAIL環境変数を設定してください" unless user

    # 問題ごとにグループ化
    questions_data = {}

    CSV.foreach("db/seeds/questions.csv", headers: true) do |row|
      title = row["title"]

      # 問題データを初期化
      questions_data[title] ||= {
        description: row["description"],
        category_name: row["category_name"],
        card_sets: {}
      }

      # origin_wordをキーにしてカードセットを管理
      origin_word = row["origin_word"]
      questions_data[title][:card_sets][origin_word] ||= []

      # related_wordsを配列に追加（カンマ区切りで分割）
      related_words = row["related_words"].split(",").map(&:strip)
      questions_data[title][:card_sets][origin_word].concat(related_words)
    end

    # 重複チェック
    existing_titles = Question.where(title: questions_data.keys).pluck(:title)
    if existing_titles.any?
      puts "エラー: 以下の問題タイトルは既に存在します"
      existing_titles.each { |title| puts "  - #{title}" }
      raise "重複する問題タイトルが見つかりました。処理を中断します。"
    end

    # 問題ごとに作成
    questions_data.each do |title, data|
      # カテゴリを検索
      category = Category.find_by(name: data[:category_name])

      # 問題を作成
      question = user.questions.create!(
        title: title,
        description: data[:description],
        category: category
      )

      # カードセットを作成
      data[:card_sets].each do |origin_word, related_words_array|
        origin = question.origin_words.create!(
          origin_word: origin_word
        )

        # related_wordsを作成
        related_words_array.each do |word|
          origin.related_words.create!(related_word: word)
        end
      end

      puts "✓ #{question.title} (カードセット: #{data[:card_sets].size}個)"
    end

    puts "インポート完了！"
  end
end
