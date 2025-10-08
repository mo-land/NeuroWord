require 'rails_helper'

RSpec.describe OriginWord, type: :model do
  describe "アソシエーション" do
    context "questionとの関係" do
      it "questionに所属している" do
        should belong_to(:question)
      end

      it "questionが存在しない場合は無効である" do
        origin_word = build(:origin_word, question: nil)
        expect(origin_word).to be_invalid
      end
    end

    context "related_wordsとの関係" do
      it "related_wordsを持つ" do
        should have_many(:related_words).dependent(:destroy)
      end

      it "origin_wordを削除すると関連するrelated_wordsも削除される" do
        origin_word = create(:origin_word, related_words_list: [ "関連語1", "関連語2" ])
        expect { origin_word.destroy }.to change { RelatedWord.count }.by(-2)
      end
    end
  end
end
