module ApplicationHelper
  def page_title(title = "")
    base_title = "NeuroWord～仲間の言葉を見つけよう！～"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def default_meta_tags(url: "https://res.cloudinary.com/dyafcag5y/image/upload/v1752075435/iyj9hdmhh8r4njmyrwwr.png")
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
      },
       twitter: {
        card: "summary_large_image",
        image: url
      }
    }
  end

   def turbo_stream_flash
    turbo_stream.update "flash", partial: "shared/flash_messages"
  end
end
