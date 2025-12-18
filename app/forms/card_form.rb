class CardForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :origin_word, :string
  attribute :related_word, :string
  attribute :question_id, :integer

  validates :origin_word, presence: true, length: { maximum: 50 }
  validates :related_word, presence: true, length: { maximum: 100 }
  validate :question_total_cards_limit
  validate :origin_word_uniqueness_within_question
  validate :related_word_uniqueness_within_question

  def save
    return false unless valid?

    question = Question.find(question_id)
    @origin_word_record = question.origin_words.create(origin_word: origin_word)

    if @origin_word_record.persisted?
      @origin_word_record.related_words.create(related_word: related_word)
      @origin_word_record
    else
      @origin_word_record.errors.full_messages.each do |message|
        errors.add(:base, message)
      end
      false
    end
  end

  def origin_word_id
    @origin_word_record&.id
  end

  def words_count
    1 + (related_words&.compact_blank&.count || 0)
  end

  private

  def question_total_cards_limit
    return unless question_id.present?

    question = Question.find(question_id)
    new_cards_count = 2 # 起点語1 + 関連語1
    unless question.can_add_card_set?
      total_count = question.total_cards_count + new_cards_count
      errors.add(:base, "このカードセットを追加すると総カード数が10枚を超えます（予想枚数：#{total_count}枚）")
    end
  end
  
  def origin_word_uniqueness_within_question
    return unless question_id.present? && origin_word.present?

    question = Question.find(question_id)
    # 同じ問題内の全てのorigin_wordsと重複チェック
    # 同じ問題内の重複があると、ゲームで正しい組み合わせを選ぶのに支障が出るため
    existing_origin_words = OriginWord.where(origin_words: { question_id: question.id }).where(origin_word: origin_word)
    
    if existing_origin_words.exists?
      errors.add(:base, "【#{origin_word}】は既にこの問題内で使用されています")
    end
  end
  
  def related_word_uniqueness_within_question
    return unless question_id.present? && related_word.present?
    
    question = Question.find(question_id)
    # 同じ問題内の全てのrelated_wordsと重複チェック
    # 同じ問題内の重複があると、ゲームで正しい組み合わせを選ぶのに支障が出るため
    existing_related_words = RelatedWord.joins(:origin_word)
                                        .where(origin_words: { question_id: question.id })
                                        .where(related_word: related_word)

    if existing_related_words.exists?
      errors.add(:base, "【#{related_word}】は既にこの問題内で使用されています")
    end
  end
end
