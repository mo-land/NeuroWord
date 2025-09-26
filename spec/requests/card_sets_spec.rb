require 'rails_helper'

RSpec.describe "CardSets", type: :request do
  # let(:user) { create(:user) }
  # let(:question) { create(:question, user: user) }
  # let(:card_set) { create(:card_set, question: question) }
  # let(:valid_params) { { card_set: { origin_word: "起点語", related_words: ["関連語1", "関連語2"]  } } }

  describe "GET #index" do
    # before { sign_in user }

    it "カードセット一覧が正常に表示される" do
    end

    context "ログインしていないユーザー" do
      it "ログインページにリダイレクトされる" do
      end
    end
  end

  describe "GET #show" do
    it "カードセット詳細が正常に表示される" do
    end

    context "ログインしていないユーザー" do
      it "ログインページにリダイレクトされる" do
      end
    end
  end

  describe "GET #new" do
    # before { sign_in user }

    it "新規作成ページが正常に表示される" do
    end

    context "カード数上限の場合" do
      it "アラートメッセージと共にリダイレクトされる" do
      end
    end

    context "他のユーザーの問題の場合" do
      it "アクセスできない" do
      end
    end
  end

  describe "POST #create" do
    # before { sign_in user }

    context "有効なパラメータの場合" do
      it "カードセットが作成される" do
      end

      it "問題詳細ページにリダイレクトされる" do
      end
    end

    context "無効なパラメータの場合" do
      it "カードセットが作成されない" do
      end

      it "新規作成ページが再表示される" do
      end
    end

    context "カード数制限チェック" do
      it "上限を超える場合は作成できない" do
      end
    end
  end

  describe "GET #edit" do
    # before { sign_in user }

    it "編集ページが正常に表示される" do
    end

    context "他のユーザーのカードセット" do
      it "アクセスできない" do
      end
    end
  end

  describe "PATCH/PUT #update" do
    # before { sign_in user }

    context "有効なパラメータの場合" do
      it "カードセットが更新される" do
      end

      it "問題詳細ページにリダイレクトされる" do
      end
    end

    context "無効なパラメータの場合" do
      it "カードセットが更新されない" do
      end

      it "編集ページが再表示される" do
      end
    end
  end

  describe "DELETE #destroy" do
    # before { sign_in user }

    it "カードセットが削除される" do
    end

    it "問題詳細ページにリダイレクトされる" do
    end

    context "他のユーザーのカードセット" do
      it "削除できない" do
      end
    end
  end
end