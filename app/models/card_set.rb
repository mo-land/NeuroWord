class CardSet < ApplicationRecord
  belongs_to :question
  
  validates :origin_word, presence: true, length: { maximum: 40 }
  validate :minimum_related_words_required
  validate :related_words_format
  validate :related_words_length
  validate :question_total_cards_limit
  
  # 従来のシャッフル機能（後方互換性）
  def all_cards_shuffled
    cards = [{ word: origin_word, type: :origin, set_id: id }]
    
    related_words.each do |word|
      cards << {
        word: word,
        type: :related,
        set_id: id
      }
    end
    
    cards.shuffle
  end
  
  # 新しいゲーム形式用
  def origin_card_data
    {
      word: origin_word,
      set_id: id,
      type: :origin,
      css_class: "origin-card"
    }
  end
  
  def related_cards_data
    related_words.map do |word|
      {
        word: word,
        set_id: id,
        type: :related,
        css_class: "related-card"
      }
    end
  end
  
  def cards_count
    1 + (related_words&.compact_blank&.count || 0)
  end
  
  # 関連語に指定の単語が含まれているかチェック
  def includes_related_word?(word)
    related_words&.include?(word)
  end
  
  private
  
  def minimum_related_words_required
    if related_words.blank? || related_words.compact_blank.count < 1
      errors.add(:related_words, 'は1つ以上必要です')
    end
  end
  
  def related_words_format
    return if related_words.blank?
    
    unless related_words.is_a?(Array) && related_words.all? { |word| word.is_a?(String) }
      errors.add(:related_words, 'の形式が不正です')
    end
  end
  
  def related_words_length
    return if related_words.blank?
    
    related_words.each_with_index do |word, index|
      if word.present? && word.length > 40
        errors.add(:related_words, "の#{index + 1}番目は40文字以内で入力してください")
      end
    end
  end
  
  def question_total_cards_limit
    return unless question.present?
    
    other_card_sets_count = question.card_sets.reject { |cs| cs == self }.sum(&:cards_count)
    current_cards_count = cards_count
    total_count = other_card_sets_count + current_cards_count
    
    if total_count > 10
      errors.add(:base, "このカードセットを追加すると総カード数が10枚を超えます（予想枚数：#{total_count}枚）")
    end
  end
end