class StaticPagesController < ApplicationController

  def top
    set_dynamic_ogp_image
  end

  def terms;end
  
  def privacy_policy;end
  
  def contact;end

  private

  def set_dynamic_ogp_image
    case params[:from]
    when "batch_result"
      # まとめてプレイモード結果からのシェア（batch_result.html.erb からのリンク）
      # パラメータから問題IDと総数を取得（例: q=123,456,789&total=5）
      if params[:q].present?
        question_ids = params[:q].split(",").first(3).map(&:to_i)
        total_count = params[:total].to_i

        # 問題タイトルを取得（絵文字を除去）
        pattern = /[\p{Emoji}\p{Emoji_Component}&&[:^ascii:]]/

        # 問題を取得してRubyでソート（IDの順序を保持）
        questions = Question.where(id: question_ids).index_by(&:id)
        question_titles = question_ids.map.with_index(1) do |id, index|
          question = questions[id]
          next unless question

          escaped_title = question.title.gsub(pattern, "")
          "#{index}. #{escaped_title}"
        end.compact

        # 3問以上の場合は「他●問」を追加
        if total_count > 3
          remaining_count = total_count - 3
          question_titles << "他#{remaining_count}問"
        end

        titles_text = question_titles.join("%0A")
      else
        titles_text = "複数の問題"
      end

      @url = "https://res.cloudinary.com/dyafcag5y/image/upload/l_text:TakaoPGothic_60_bold:#{titles_text},co_rgb:421,w_900,c_fit/v1763119436/egmqwfndunmbjfsaa7y9.png"
    else
      # デフォルト（直接アクセスやその他）
      @url = "https://res.cloudinary.com/dyafcag5y/image/upload/v1752075435/iyj9hdmhh8r4njmyrwwr.png"
    end

    set_meta_tags(og: { image: @url }, twitter: { image: @url })
  end
end
