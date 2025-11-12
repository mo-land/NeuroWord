class Question < ApplicationRecord
  has_many :origin_words, dependent: :destroy
  has_many :question_tags, dependent: :destroy
  has_many :tags, through: :question_tags

  validates :title, uniqueness: true, presence: true, length: { maximum: 40 }
  validates :description, presence: true, length: { maximum: 150 }
  validate :maximum_total_cards_limit
  validate :validate_tag_names

  attr_accessor :tag_names

  belongs_to :user
  belongs_to :category
  has_many :game_records, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :list_questions, dependent: :destroy
  has_many :lists, through: :list_questions

  # 新しいゲーム形式用のグループ分けメソッド
  def grouped_game_cards
    origin_cards = []
    related_cards = []

    origin_words.each do |origin_word|
      # 起点カード
      origin_cards << {
        word: origin_word.origin_word,
        set_id: origin_word.id,
        type: :origin,
        css_class: "origin-card"
      }

       # 関連語カード
       origin_word.related_words.each do |related_word|
        related_cards << {
          word: related_word.related_word,
          set_id: origin_word.id,
          type: :related,
          css_class: "related-card"
        }
      end
    end

    {
      origins: origin_cards.shuffle,
      relateds: related_cards.shuffle,
      total_sets: origin_words.size
    }
  end

  # ゲームの正答チェック用
  def check_match(origin_card_id, related_word)
    origin_word = origin_words.find(origin_card_id)
    origin_word&.related_words&.pluck(:related_word)&.include?(related_word)
  end

  def valid_for_game?
    origin_words.count >= 2 && total_cards_count <= 10
  end

  def total_cards_count
    # origin_wordsが読み込まれているかチェック
    if origin_words.loaded?
      origin_words.sum do |origin_word|
        1 + (origin_word.related_words.loaded? ? origin_word.related_words.size : origin_word.related_words.count)
      end
    else
      # eager loadingされていない場合は直接SQLで計算
      origin_words.count + RelatedWord.joins(:origin_word).where(origin_words: { question_id: id }).count
    end
  end

  def remaining_cards_count
    10 - total_cards_count
  end

  def total_related_words_count
    RelatedWord.joins(:origin_word).where(origin_words: { question_id: id }).count
  end

  def can_add_card_set?(origin_word_count = 1, related_words_count = 0)
    (total_cards_count + origin_word_count + related_words_count) <= 10
  end

  def can_add_related_word?(context: :related_words)
    # カードセット追加画面では8枚まで、編集画面では10枚まで、関連語追加画面では9枚まで
    max_count = case context
    when :card_sets_new
      8
    when :card_sets_edit
      10
    else
      9
    end
    return false if total_cards_count >= max_count

    if origin_words.count == 1
      total_related_words_count < 6
    else
      true
    end
  end

  def save_tag(sent_tags)
    # タグが存在していれば、タグの名前を配列として全て取得
    current_tags = tags.pluck(:name) unless tags.nil?
    # 現在取得したタグから送られてきたタグを除いてoldtagとする
    old_tags = current_tags - sent_tags
    # 送信されてきたタグから現在存在するタグを除いたタグをnewとする
    new_tags = sent_tags - current_tags

    # 古いタグを消す
    old_tags.each do |old|
      tags.delete Tag.find_by(name: old)
    end

    # 新しいタグを保存
    new_tags.each do |new|
      new_question_tag = Tag.find_or_create_by(name: new)
      tags << new_question_tag
    end
  end

  # 任意：リスト登録状況を確認するメソッド
  def liked_by?(user)
    ListQuestion.joins(:list).where(question_id: id, lists: { user_id: user.id }).exists?
  end

  def liked_users
    User.joins(lists: :list_questions).where(list_questions: { question_id: id }).distinct
  end

  def liked_users_count
    liked_users.count
  end

  private

  def maximum_total_cards_limit
    if total_cards_count > 10
      errors.add(:base, "カードの総数は10枚以内にしてください（現在：#{total_cards_count}枚）")
    end
  end

  def validate_tag_names
    return unless tag_names.present?

    names = tag_names.split(",")

    names.each do |name|
      if name.length > 20
        errors.add(:base, "タグは20文字以内で入力してください")
      end
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
