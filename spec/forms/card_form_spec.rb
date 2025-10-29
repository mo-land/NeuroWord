require 'rails_helper'

RSpec.describe CardForm, type: :model do
  describe "バリデーション" do
    let(:question) { create(:question) }

    context "origin_wordフィールドのテスト" do
      it "origin_wordが存在しない場合は無効である" do
        form = CardForm.new(origin_word: nil, related_word: "関連語", question_id: question.id)
        expect(form).to be_invalid
        expect(form.errors[:origin_word]).to include("を入力してください")
      end

      it "origin_wordは50文字以下の場合のみ有効である" do
        form_valid = CardForm.new(origin_word: "a" * 50, related_word: "関連語", question_id: question.id)
        expect(form_valid).to be_valid

        form_invalid = CardForm.new(origin_word: "a" * 51, related_word: "関連語", question_id: question.id)
        expect(form_invalid).to be_invalid
        expect(form_invalid.errors[:origin_word]).to include("は50文字以内で入力してください")
      end
    end

    context "related_wordフィールドのテスト" do
      it "related_wordが存在しない場合は無効である" do
        form = CardForm.new(origin_word: "起点語", related_word: nil, question_id: question.id)
        expect(form).to be_invalid
        expect(form.errors[:related_word]).to include("を入力してください")
      end

      it "related_wordは100文字以下の場合のみ有効である" do
        form_valid = CardForm.new(origin_word: "起点語", related_word: "a" * 100, question_id: question.id)
        expect(form_valid).to be_valid

        form_invalid = CardForm.new(origin_word: "起点語", related_word: "a" * 101, question_id: question.id)
        expect(form_invalid).to be_invalid
        expect(form_invalid.errors[:related_word]).to include("は100文字以内で入力してください")
      end
    end

    context "question内での関連語の重複チェック" do
      it "同じquestion内で既に使用されている関連語の場合は無効である" do
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "重複語" ])
        form = CardForm.new(origin_word: "起点2", related_word: "重複語", question_id: question.id)
        expect(form).to be_invalid
        expect(form.errors[:base]).to include("【重複語】は既にこの問題内で使用されています")
      end

      it "異なるquestion間では同じ関連語を使用できる" do
        question2 = create(:question)
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "共通語" ])
        form = CardForm.new(origin_word: "起点2", related_word: "共通語", question_id: question2.id)
        expect(form).to be_valid
      end
    end

    context "質問全体のカード総数制限チェック" do
      it "追加後の総カード数が10枚以下の場合は有効である" do
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連1", "関連2", "関連3" ])  # 4枚
        create(:origin_word, question: question, origin_word: "起点2", related_words_list: [ "関連4", "関連5" ])  # 3枚
        # 現在7枚、新規追加で2枚 → 合計9枚
        form = CardForm.new(origin_word: "起点3", related_word: "関連6", question_id: question.id)
        expect(form).to be_valid
      end

      it "追加後の総カード数が11枚以上になる場合は無効である" do
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連1", "関連2", "関連3" ])  # 4枚
        create(:origin_word, question: question, origin_word: "起点2", related_words_list: [ "関連4", "関連5", "関連6", "関連7" ])  # 5枚
        # 現在9枚、新規追加で2枚 → 合計11枚
        form = CardForm.new(origin_word: "起点3", related_word: "関連8", question_id: question.id)
        expect(form).to be_invalid
        expect(form.errors[:base]).to include("このカードセットを追加すると総カード数が10枚を超えます（予想枚数：11枚）")
      end
    end

    context "特殊文字を含む単語の場合" do
      it "特殊文字を含む単語も正しく処理する" do
        form = CardForm.new(origin_word: "特殊文字！@#$%", related_word: "記号&*()", question_id: question.id)
        expect(form).to be_valid
      end
    end
  end

  describe "#save" do
    let(:question) { create(:question) }

    context "バリデーションが成功する場合" do
      it "origin_wordとrelated_wordを保存する" do
        form = CardForm.new(origin_word: "起点語", related_word: "関連語", question_id: question.id)
        expect { form.save }.to change { OriginWord.count }.by(1)
                                                          .and change { RelatedWord.count }.by(1)
      end

      it "保存したorigin_word_recordを返す" do
        form = CardForm.new(origin_word: "起点語", related_word: "関連語", question_id: question.id)
        result = form.save
        expect(result).to be_a(OriginWord)
        expect(result.origin_word).to eq("起点語")
      end
    end

    context "バリデーションが失敗する場合" do
      it "レコードを保存せずfalseを返す" do
        form = CardForm.new(origin_word: nil, related_word: "関連語", question_id: question.id)
        expect { form.save }.not_to change { OriginWord.count }
        expect(form.save).to be false
      end
    end
  end

  describe "#origin_word_id" do
    let(:question) { create(:question) }

    it "保存後にorigin_wordのidを取得できる" do
      form = CardForm.new(origin_word: "起点語", related_word: "関連語", question_id: question.id)
      form.save
      expect(form.origin_word_id).to be_present
      expect(form.origin_word_id).to eq(OriginWord.last.id)
    end

    it "保存前はnilを返す" do
      form = CardForm.new(origin_word: "起点語", related_word: "関連語", question_id: question.id)
      expect(form.origin_word_id).to be_nil
    end
  end
end
