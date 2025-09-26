require 'rails_helper'

RSpec.describe "CardSets", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "#all_cards_shuffled" do
    context "起点カードと関連語カードが存在する場合" do
      it "起点カードと関連語カードを含む全カードを取得できる" do
      end

      it "各カードに適切な属性が設定される" do
      end

      it "取得したカードがシャッフルされている" do
      end
    end

    context "関連語が存在しない場合" do
      it "起点カードのみを含む配列を返す" do
      end
    end
  end

  describe "#origin_card_data" do
    context "起点カードデータの生成" do
      it "適切な属性を持つハッシュを返す" do
      end

      it "wordにorigin_wordが設定される" do
      end

      it "typeに:originが設定される" do
      end

      it "set_idにカードセットのIDが設定される" do
      end

      it "css_classに'origin-card'が設定される" do
      end
    end
  end

  describe "#related_cards_data" do
    context "関連語カードデータの生成" do
      it "全ての関連語がカードデータに変換される" do
      end

      it "各カードに適切な属性が設定される" do
      end

      it "typeに:relatedが設定される" do
      end

      it "css_classに'related-card'が設定される" do
      end
    end

    context "関連語が存在しない場合" do
      it "空の配列を返す" do
      end
    end
  end
  
  describe "#includes_related_word?" do
    context "指定した単語が関連語に含まれる場合" do
      it "trueを返す" do
      end
    end

    context "指定した単語が関連語に含まれない場合" do
      it "falseを返す" do
      end
    end

    context "関連語が空の場合" do
      it "falseを返す" do
      end
    end

    context "関連語がnilの場合" do
      it "falseを返す" do
      end
    end

    context "引数がnilの場合" do
      it "falseを返す" do
      end
    end
  end
end
