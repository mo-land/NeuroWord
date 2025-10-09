require 'rails_helper'

RSpec.describe RelatedWord, type: :model do
  describe "バリデーション" do
    context "question内での重複チェック" do
      it "同じquestion内の別のorigin_wordに紐づく関連語と重複する場合は無効である" do
        question = create(:question)
        origin_word1 = create(:origin_word, question: question)
        origin_word2 = create(:origin_word, question: question)
        create(:related_word, origin_word: origin_word1, related_word: "重複チェック")
        duplicate_word = build(:related_word, origin_word: origin_word2, related_word: "重複チェック")
        expect(duplicate_word).to be_invalid
        expect(duplicate_word.errors[:related_word]).to include("は既にこの問題内で使用されています")
      end

      it "異なるquestion間では同じ関連語を持てる" do
        question1 = create(:question)
        question2 = create(:question)
        origin_word1 = create(:origin_word, question: question1)
        origin_word2 = create(:origin_word, question: question2)
        create(:related_word, origin_word: origin_word1, related_word: "共通語")
        same_word = build(:related_word, origin_word: origin_word2, related_word: "共通語")
        expect(same_word).to be_valid
      end
    end
  end

  describe "アソシエーション" do
    context "origin_wordとの関係" do
      it "origin_wordに所属している" do
        should belong_to(:origin_word)
      end
    end
  end
end
