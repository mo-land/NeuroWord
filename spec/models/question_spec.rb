require 'rails_helper'

RSpec.describe Question, type: :model do
  describe "バリデーション" do
    context "titleフィールドのテスト" do
      it "titleが存在しない場合は無効である" do
      end

      it "titleが空文字の場合は無効である" do
      end

      it "titleが重複している場合は無効である" do
      end

      it "titleが40文字以下の場合は有効である" do
      end

      it "titleが41文字以上の場合は無効である" do
      end
    end

    context "descriptionフィールドのテスト" do
      it "descriptionが存在しない場合は無効である" do
      end

      it "descriptionが空文字の場合は無効である" do
      end

      it "descriptionが150文字以下の場合は有効である" do
      end

      it "descriptionが151文字以上の場合は無効である" do
      end
    end

    context "カード総数制限のテスト" do
      it "カード総数が10枚以下の場合は有効である" do
      end

      it "カード総数が11枚以上の場合は無効である" do
      end
    end

    context "タグ名のバリデーション" do
      it "タグ名が20文字以下の場合は有効である" do
      end

      it "タグ名が21文字以上の場合は無効である" do
      end

      it "複数のタグがカンマ区切りで正しく処理される" do
      end
    end
  end

  describe "アソシエーション" do
    context "card_setsとの関係" do
      it "複数のcard_setsを持つことができる" do
      end

      it "Question削除時にcard_setsも削除される" do
      end
    end

    context "tagsとの関係" do
      it "question_tagsを通じて複数のtagsと関連付けられる" do
      end

      it "Question削除時にquestion_tagsも削除される" do
      end
    end

    context "userとの関係" do
      it "userに所属している" do
      end

      it "userが存在しない場合は無効である" do
      end
    end

    context "game_recordsとの関係" do
      it "複数のgame_recordsを持つことができる" do
      end

      it "Question削除時にgame_recordsも削除される" do
      end
    end

    context "requestsとの関係" do
      it "複数のrequestsを持つことができる" do
      end

      it "Question削除時にrequestsも削除される" do
      end
    end
  end

  describe "#total_cards_count" do
    context "複数のカードセットが存在する場合" do
      it "起点カードと関連語カードの合計を正しく計算する" do
      end
    end

    context "カードセットが存在しない場合" do
      it "0を返す" do
      end
    end

    context "関連語が空のカードセットがある場合" do
      it "起点カードのみをカウントする" do
      end
    end
  end

  describe "#remaining_cards_count" do
    context "カードが存在する場合" do
      it "10から現在のカード数を引いた値を返す" do
      end
    end

    context "カードが10枚の場合" do
      it "0を返す" do
      end
    end
  end

  describe ".ransackable_attributes" do
    context "検索可能な属性の設定" do
      it "titleとdescriptionのみを返す" do
      end

      it "他の属性は検索対象に含まれない" do
      end
    end
  end

  describe ".ransackable_associations" do
    context "検索可能な関連の設定" do
      it "userのみを返す" do
      end

      it "他の関連は検索対象に含まれない" do
      end
    end
  end

  describe "プライベートメソッド" do
    context "maximum_total_cards_limitバリデーション" do
      it "カード総数が10枚以下の場合はエラーが発生しない" do
      end

      it "カード総数が11枚以上の場合はエラーが発生する" do
      end
    end

    context "validate_tag_namesバリデーション" do
      it "タグ名が20文字以下の場合はエラーが発生しない" do
      end

      it "タグ名が21文字以上の場合はエラーが発生する" do
      end

      it "tag_namesが空の場合はバリデーションをスキップする" do
      end
    end
  end
end
