class Question < ApplicationRecord
  has_many :card_sets, dependent: :destroy

  validates :title, presence: true, length: { maximum: 40 }
  validates :description, presence: true, length: { maximum: 150 }
  # validate :minimum_card_sets_required, on: :create
  validate :maximum_total_cards_limit

  belongs_to :user

  # 従来のシャッフル機能（後方互換性）
  def shuffled_game_cards
    all_cards = []

    card_sets.each do |card_set|
      all_cards.concat(card_set.all_cards_shuffled)
    end

    all_cards.shuffle
  end

  # 新しいゲーム形式用のグループ分けメソッド
  def grouped_game_cards
    origin_cards = []
    related_cards = []

    card_sets.each do |card_set|
      # 起点カード
      origin_cards << {
        word: card_set.origin_word,
        set_id: card_set.id,
        type: :origin,
        css_class: "origin-card"
      }

      # 関連語カード
      card_set.related_words.each do |word|
        related_cards << {
          word: word,
          set_id: card_set.id,
          type: :related,
          css_class: "related-card"
        }
      end
    end

    {
      origins: origin_cards.shuffle,
      relateds: related_cards.shuffle,
      total_sets: card_sets.count
    }
  end

  # ゲームの正答チェック用
  def check_match(origin_card_id, related_word)
    card_set = card_sets.find(origin_card_id)
    card_set&.related_words&.include?(related_word)
  end

  def valid_for_game?
    card_sets.count >= 2 && card_sets.all?(&:valid?) && total_cards_count <= 10
  end

  def total_cards_count
    card_sets.sum do |card_set|
      1 + (card_set.related_words&.compact_blank&.count || 0)
    end
  end

  def remaining_cards_count
    10 - total_cards_count
  end

  def can_add_card_set?(origin_word_count = 1, related_words_count = 0)
    (total_cards_count + origin_word_count + related_words_count) <= 11
  end

  private

  # def minimum_card_sets_required
  #   errors.add(:base, 'カードセットは2組以上必要です') if card_sets.count < 2
  # end

  def maximum_total_cards_limit
    if total_cards_count > 10
      errors.add(:base, "カードの総数は10枚以内にしてください（現在：#{total_cards_count}枚）")
    end
  end

  # Runsackホワイトリスト
  def self.ransackable_attributes(auth_object = nil)
    [ "title", "description" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "user" ]
  end
end
