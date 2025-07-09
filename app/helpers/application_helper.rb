module ApplicationHelper
  def default_meta_tags
    {
      site: "NeuroWord～仲間の言葉を見つけよう！～",
      title: "NeuroWord～仲間の言葉を見つけよう！～",
      reverse: true,
      charset: "utf-8",
      description: "「NeuroWord～仲間の言葉を見つけよう！～」は、単語や用語とその関連語・説明を一覧表示し、正しい組み合わせを選んでいくWebゲームアプリです。",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: "NeuroWord～仲間の言葉を見つけよう！～",
        title: "NeuroWord～仲間の言葉を見つけよう！～",
        description: "「NeuroWord～仲間の言葉を見つけよう！～」は、単語や用語とその関連語・説明を一覧表示し、正しい組み合わせを選んでいくWebゲームアプリです。",
        type: "website",
        url: request.original_url,
        locale: "ja_JP"
      }
    }
  end
end
