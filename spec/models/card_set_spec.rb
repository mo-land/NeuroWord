require 'rails_helper'

RSpec.describe CardSet, type: :model do
  describe "バリデーション" do
    context "origin_wordフィールドのテスト" do
      it "origin_wordは存在する場合のみ有効か" do
        should validate_presence_of(:origin_word)
      end

      it "origin_wordは40文字以下の場合のみ有効か" do
        should validate_length_of(:origin_word).is_at_most(40)
      end
    end

    context "関連語の最小個数チェック" do
      it "関連語が存在しない場合は無効である" do
        card_set = build(:card_set, related_words: [])
        expect(card_set).to be_invalid
        expect(card_set.errors[:related_words]).to include("は1つ以上必要です")
      end

      it "関連語がすべて空白の場合は無効である" do
        card_set = build(:card_set, related_words: [ "", " ", nil ])
        expect(card_set).to be_invalid
        expect(card_set.errors[:related_words]).to include("は1つ以上必要です")
      end

      # it "有効な関連語が1つ以上ある場合は有効である" do
      # end
    end

    context "関連語の長さ制限チェック" do
      it "関連語は40文字以下の場合のみ有効か" do
        card_set = build(:card_set, related_words: [ "a" * 40 ])
        expect(card_set).to be_valid

        card_set_invalid = build(:card_set, related_words: [ "a" * 41 ])
        expect(card_set_invalid).to be_invalid
        expect(card_set_invalid.errors[:related_words]).to include("の1番目は40文字以内で入力してください")
      end

      it "複数の関連語で長さ制限を超える場合は適切なエラーメッセージを表示する" do
        card_set = build(:card_set, related_words: [ "a" * 41, "b" * 41 ])
        expect(card_set).to be_invalid
        expect(card_set.errors[:related_words]).to include("の1番目は40文字以内で入力してください")
        expect(card_set.errors[:related_words]).to include("の2番目は40文字以内で入力してください")
      end
    end

    context "質問全体のカード総数制限チェック" do
      it "追加後の総カード数が10枚以下の場合は有効である" do
        question = create(:question)
        create(:card_set, question: question, related_words: [ "関連語1", "関連語2", "関連語3" ])
        card_set = build(:card_set, question: question, related_words: [ "新関連語1", "新関連語2", "新関連語3", "新関連語4", "新関連語5" ])
        expect(card_set).to be_valid
      end

      it "追加後の総カード数が11枚以上になる場合は無効である" do
        question = create(:question)
        create(:card_set, question: question, related_words: [ "関連語1", "関連語2", "関連語3", "関連語4" ])
        add_card_set = create(:card_set, question: question, related_words: [ "新関連語1", "新関連語2", "新関連語3", "新関連語4", "新関連語5", "新関連語6" ])
        expect(question).to be_invalid
        expect(question.errors[:base]).to include("カードの総数は10枚以内にしてください（現在：12枚）")
      end

      it "questionが存在しない場合はバリデーションをスキップする" do
        card_set = build(:card_set, question: nil, related_words: Array.new(20, "関連語"))
        card_set.valid?
        expect(card_set.errors[:base]).to be_empty
      end

      it "他のカードセットとの合計カード数を正しく計算する" do
        question = create(:question)
        create(:card_set, question: question, related_words: [ "関連語1" ])
        create(:card_set, question: question, related_words: [ "関連語2", "関連語3" ])
        card_set = build(:card_set, question: question, related_words: [ "新関連語1", "新関連語2", "新関連語3", "新関連語4", "新関連語5" ])
        expect(card_set).to be_valid
      end
    end
  end

  describe "アソシエーション" do
    context "questionとの関係" do
      it "questionに所属している" do
        should belong_to(:question)
      end

      it "questionが存在しない場合は無効である" do
        card_set = build(:card_set, question: nil)
        expect(card_set).to be_invalid
      end
    end
  end

  describe "#cards_count" do
    context "関連語が存在する場合" do
      it "起点カード1枚＋関連語カード数の合計を返す" do
        card_set = build(:card_set, related_words: [ "関連語1", "関連語2", "関連語3" ])
        expect(card_set.cards_count).to eq(4)
      end
    end

    context "関連語が存在しない場合" do
      it "1を返す" do
        card_set = build(:card_set, related_words: [])
        expect(card_set.cards_count).to eq(1)
      end
    end

    context "関連語に空文字が含まれる場合" do
      it "空文字を除外してカウントする" do
        card_set = build(:card_set, related_words: [ "関連語1", "", " ", "関連語2", nil ])
        expect(card_set.cards_count).to eq(3)
      end
    end

    context "関連語がnilの場合" do
      it "1を返す" do
        card_set = build(:card_set, related_words: nil)
        expect(card_set.cards_count).to eq(1)
      end
    end
  end

  # describe "プライベートメソッド" do
  #   context "minimum_related_words_requiredバリデーション" do
  #     it "関連語が空の場合はエラーを追加する" do
  #     end

  #     it "関連語がすべて空白の場合はエラーを追加する" do
  #     end

  #     it "有効な関連語が1つ以上ある場合はエラーを追加しない" do
  #     end
  #   end

  #   context "related_words_formatバリデーション" do
  #     it "関連語が配列でない場合はエラーを追加する" do
  #     end

  #     it "関連語の要素が文字列でない場合はエラーを追加する" do
  #     end

  #     it "関連語が正しい形式の場合はエラーを追加しない" do
  #     end

  #     it "関連語が空の場合はバリデーションをスキップする" do
  #     end
  #   end

  #   context "related_words_lengthバリデーション" do
  #     it "関連語の長さが40文字以下の場合はエラーを追加しない" do
  #     end

  #     it "関連語の長さが41文字以上の場合はエラーを追加する" do
  #     end

  #     it "複数の関連語で長さ制限を超える場合は各々にエラーを追加する" do
  #     end

  #     it "空文字の関連語は長さチェックをスキップする" do
  #     end

  #     it "関連語が空の場合はバリデーションをスキップする" do
  #     end
  #   end

  #   context "question_total_cards_limitバリデーション" do
  #     it "総カード数が10枚以下の場合はエラーを追加しない" do
  #     end

  #     it "総カード数が11枚以上になる場合はエラーを追加する" do
  #     end

  #     it "他のカードセットのカード数を正しく計算する" do
  #     end

  #     it "自分自身のカードセットは計算から除外する" do
  #     end

  #     it "questionが存在しない場合はバリデーションをスキップする" do
  #     end
  #   end
  # end

  describe "エッジケース" do
    # context "関連語にnilや空文字が混在する場合" do
    #   it "有効な関連語のみを処理する" do
    #     card_set = build(:card_set, related_words: ["関連語1", nil, "", " ", "関連語2"])
    #     expect(card_set).to be_valid
    #     expect(card_set.cards_count).to eq(3)
    #   end
    # end

    # context "同じ関連語が重複する場合" do
    #   it "重複した関連語も含めて処理する" do
    #     card_set = build(:card_set, related_words: ["関連語1", "関連語1", "関連語2"])
    #     expect(card_set).to be_valid
    #     expect(card_set.cards_count).to eq(4)
    #   end
    # end

    context "特殊文字を含む単語の場合" do
      it "特殊文字を含む単語も正しく処理する" do
        card_set = build(:card_set, origin_word: "特殊文字！@#$%", related_words: [ "記号&*()" ])
        expect(card_set).to be_valid
      end
    end

    context "非常に長い文字列での動作" do
      it "制限を超える長さの文字列で適切にエラーを発生させる" do
        card_set = build(:card_set, origin_word: "a" * 50)
        expect(card_set).to be_invalid
        expect(card_set.errors[:origin_word]).to include("は40文字以内で入力してください")
      end
    end
  end
end
