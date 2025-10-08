require 'rails_helper'

RSpec.describe Question, type: :model do
  subject { create(:question) }

  describe "バリデーション" do
    context "titleフィールドのテスト" do
      it "titleは存在する場合のみ有効か" do
        should validate_presence_of(:title)
      end

      it "titleはユニークである場合のみ有効か" do
        should validate_uniqueness_of(:title)
      end

      it "titleは40文字以下で設定されている場合のみ有効か" do
        should validate_length_of(:title).is_at_most(40)
      end
    end

    context "descriptionフィールドのテスト" do
      it "descriptionは存在する場合のみ有効か" do
        should validate_presence_of(:description)
      end

      it "descriptionは150文字以下で設定されている場合のみ有効か" do
        should validate_length_of(:description).is_at_most(150)
      end
    end

    context "カード総数制限のテスト" do
      it "カード総数が10枚以下の場合は有効である" do
        question = create(:question)
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連1", "関連2" ])  # 3枚
        create(:origin_word, question: question, origin_word: "起点2", related_words_list: [ "関連3", "関連4" ])  # 3枚
        create(:origin_word, question: question, origin_word: "起点3", related_words_list: [ "関連5", "関連6", "関連7" ])  # 4枚
        expect(question.total_cards_count).to eq(10)
        expect(question).to be_valid
      end

      it "カード総数が11枚以上の場合は無効である" do
        question = create(:question)
        # 11枚になるように設定
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連1", "関連2" ])  # 3枚
        create(:origin_word, question: question, origin_word: "起点2", related_words_list: [ "関連3", "関連4", "関連5" ])  # 4枚
        create(:origin_word, question: question, origin_word: "起点3", related_words_list: [ "関連6", "関連7", "関連8" ])  # 4枚
        expect(question.total_cards_count).to eq(11)
        expect(question).to be_invalid
      end
    end

    context "タグ名のバリデーション" do
      let(:question) { build(:question) }

      it "タグ名が20文字以下の場合は有効である" do
        question.tag_names = "AAAAABBBBBCCCCCDDDDD"
        expect(question).to be_valid
      end

      it "タグ名が21文字以上の場合は無効である" do
        question.tag_names = "AAAAABBBBBCCCCCDDDDDE"
        expect(question).to be_invalid
      end

      xit "複数のタグがカンマ区切りで正しく処理される" do
      end
    end
  end

  describe "アソシエーション" do
    context "card_setsとの関係" do
      it "複数のcard_setsを持つことができ、Question削除時にcard_setsも削除される" do
        should have_many(:card_sets).dependent(:destroy)
      end
    end

    context "tagsとの関係" do
      it "question_tagsを通じて複数のtagsと関連付けられる" do
        should have_many(:tags).through(:question_tags)
      end

      it "複数のquestion_tagsを持つことができ, Question削除時にquestion_tagsも削除される" do
        should have_many(:question_tags).dependent(:destroy)
      end
    end

    context "userとの関係" do
      it "userに所属している" do
        should belong_to(:user)
      end
    end

    context "game_recordsとの関係" do
      it '複数のgame_recordsを持つことができ, Question削除時にgame_recordsも削除される' do
        should have_many(:game_records).dependent(:destroy)
      end
    end

    context "requestsとの関係" do
      it '複数のrequestsを持つことができ, Question削除時にrequestsも削除される' do
        should have_many(:requests).dependent(:destroy)
      end
    end
  end

  describe "#total_cards_count" do
    context "複数のカードセットが存在する場合" do
      it "起点カードと関連語カードの合計を正しく計算する" do
        question = create(:question)
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連1", "関連2" ])  # 3枚
        create(:origin_word, question: question, origin_word: "起点2", related_words_list: [ "関連3" ])  # 2枚
        expect(question.total_cards_count).to eq(5)
      end
    end

    context "カードセットが存在しない場合" do
      it "0を返す" do
        question = create(:question)
        expect(question.total_cards_count).to eq(0)
      end
    end
  end

  describe "#remaining_cards_count" do
    context "カードが存在する場合" do
      it "10から現在のカード数を引いた値を返す" do
        question = create(:question)
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連1", "関連2" ])  # 3枚
        expect(question.remaining_cards_count).to eq(7)
      end
    end

    context "カードが10枚の場合" do
      it "0を返す" do
        question = create(:question)
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連1", "関連2" ])  # 3枚
        create(:origin_word, question: question, origin_word: "起点2", related_words_list: [ "関連3", "関連4" ])  # 3枚
        create(:origin_word, question: question, origin_word: "起点3", related_words_list: [ "関連5", "関連6", "関連7" ])  # 4枚
        expect(question.total_cards_count).to eq(10)
        expect(question.remaining_cards_count).to eq(0)
      end
    end
  end

  describe ".ransackable_attributes" do
    context "検索可能な属性の設定" do
      it "titleとdescriptionのみを返す" do
        expect(Question.ransackable_attributes).to contain_exactly("title", "description")
      end

      it "他の属性は検索対象に含まれない" do
        expect(Question.ransackable_attributes).not_to include("id", "created_at", "updated_at", "user_id")
      end
    end
  end

  describe ".ransackable_associations" do
    context "検索可能な関連の設定" do
      it "userのみを返す" do
        expect(Question.ransackable_associations).to contain_exactly("user")
      end

      it "他の関連は検索対象に含まれない" do
        expect(Question.ransackable_associations).not_to include("card_sets", "tags", "question_tags")
      end
    end
  end

  describe "その他プライベートメソッド" do
    context "validate_tag_namesバリデーション" do
      let(:question) { build(:question) }

      it "タグ名が20文字以下の場合はエラーが発生しない" do
        question.tag_names = "AAAAABBBBBCCCCCDDDDD"
        expect(question).to be_valid
      end

      it "タグ名が21文字以上の場合はエラーが発生する" do
        question.tag_names = "AAAAABBBBBCCCCCDDDDDE"  # 21文字

        expect(question).to be_invalid
        expect(question.errors[:base]).to include("タグは20文字以内で入力してください")
      end

      it "tag_namesが空の場合はバリデーションをスキップする" do
        question.tag_names = nil

        question.valid?
        expect(question.errors[:base]).to be_empty
      end
    end
  end
end
