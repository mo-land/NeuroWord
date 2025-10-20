FactoryBot.define do
  factory :category do
    name { '息抜き系・未分類' }

    trait :fe do
      name { '基本情報' }
    end

    trait :rails do
      name { 'Ruby on Rails' }
    end

    trait :js do
      name { 'JavaScript' }
    end

    trait :css do
      name { 'CSS' }
    end

    trait :git do
      name { 'Git' }
    end

    trait :it_others do
      name { 'その他学習（IT系）' }
    end

    trait :non_it_others do
      name { 'その他学習（IT以外）' }
    end

    trait :uncategorized do
      name { '息抜き系・未分類' }
    end

    # 親子関係付きのカテゴリ
    trait :with_children do
      after(:create) do |category|
        if category.name == '基本情報'
          technology = create(:category, name: 'テクノロジ系', parent: category)
          management = create(:category, name: 'マネジメント系', parent: category)
          strategy = create(:category, name: 'ストラテジ系', parent: category)

          [ '基礎理論', 'コンピュータシステム', '技術要素_データベース', '技術要素_ネットワーク', '技術要素_セキュリティ', '技術要素_その他', '開発技術' ].each do |name|
            create(:category, name: name, parent: technology)
          end

          [ 'プロジェクトマネジメント', 'サービスマネジメント' ].each do |name|
            create(:category, name: name, parent: management)
          end

          [ 'システム戦略', '経営戦略', '企業と法務' ].each do |name|
            create(:category, name: name, parent: strategy)
          end
        end
      end
    end
  end
end
