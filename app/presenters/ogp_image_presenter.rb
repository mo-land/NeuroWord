class OgpImagePresenter
  # 絵文字を含むタイトルでもOGP画像を生成できるよう、Cloudinaryへ渡す際に絵文字を除去するためのパターン。
  # ASCII範囲外の絵文字・絵文字構成文字を対象とする。
  EMOJI_PATTERN = /[\p{Emoji}\p{Emoji_Component}&&[:^ascii:]]/

  CREATOR_IMAGE_TEMPLATE = "https://res.cloudinary.com/dyafcag5y/image/upload/" \
    "l_text:TakaoPGothic_60_bold:～%s～%%0Aの問題を作ったよ！,co_rgb:FFF,w_900,c_fit/" \
    "v1752074827/kjwmtl03doe8m0ywkvvh.png"
  RESULT_IMAGE_TEMPLATE  = "https://res.cloudinary.com/dyafcag5y/image/upload/" \
    "l_text:TakaoPGothic_60_bold:～%s～%%0Aに挑戦したよ！,co_rgb:421,w_900,c_fit/" \
    "v1752074826/h0rhydkkhqhzlqvt1rbk.png"
  DEFAULT_IMAGE_URL      = "https://res.cloudinary.com/dyafcag5y/image/upload/" \
    "v1752075435/iyj9hdmhh8r4njmyrwwr.png"

  def initialize(question, from)
    @question = question
    @from     = from
  end

  def url
    case @from
    when "creator" then format(CREATOR_IMAGE_TEMPLATE, escaped_title)
    when "result"  then format(RESULT_IMAGE_TEMPLATE,  escaped_title)
    else DEFAULT_IMAGE_URL
    end
  end

  private

  def escaped_title
    @question.title.gsub(EMOJI_PATTERN, "")
  end
end
