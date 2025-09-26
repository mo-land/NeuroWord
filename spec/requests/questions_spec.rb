require 'rails_helper'

RSpec.describe "Questions", type: :request do
  # let(:user) { create(:user) }
  # let(:question) { create(:question, user: user) }
  # let(:valid_params) { { question: { title: "テスト問題", description: "説明" } } }
  # let(:invalid_params) { { question: { title: "", description: "" } } }

  describe "GET #index" do
    it "問題一覧ページが正常に表示される" do
    end

    it "タグ一覧が表示される" do
    end

    context "ログインしていないユーザー" do
      it "問題一覧を閲覧できる" do
      end
    end
  end

  describe "GET #show" do
    it "問題詳細ページが正常に表示される" do
    end

    context "ログインしていないユーザー" do
      it "問題詳細を閲覧できる" do
      end
    end
  end

  describe "GET #new" do
    context "ログインしているユーザー" do
      # before { sign_in user }

      it "新規作成ページが正常に表示される" do
      end
    end

    context "ログインしていないユーザー" do
      it "ログインページにリダイレクトされる" do
      end
    end
  end

  describe "POST #create" do
    # before { sign_in user }

    context "有効なパラメータの場合" do
      it "問題が作成される" do
      end

      it "カードセット作成ページにリダイレクトされる" do
      end

      it "タグが正しく処理される" do
      end
    end

    context "無効なパラメータの場合" do
      it "問題が作成されない" do
      end

      it "新規作成ページが再表示される" do
      end
    end

    context "タグの処理" do
      it "JSON形式のタグが正しく処理される" do
      end

      it "カンマ区切りのタグが正しく処理される" do
      end

      it "空のタグが適切に処理される" do
      end
    end
  end

  describe "GET #edit" do
    # before { sign_in user }

    it "編集ページが正常に表示される" do
    end

    context "他のユーザーの問題の場合" do
      it "404エラーが返される" do
      end
    end
  end

  describe "PATCH/PUT #update" do
    # before { sign_in user }

    context "有効なパラメータの場合" do
      it "問題が更新される" do
      end

      it "問題詳細ページにリダイレクトされる" do
      end

      it "タグが更新される" do
      end
    end

    context "無効なパラメータの場合" do
      it "問題が更新されない" do
      end

      it "編集ページが再表示される" do
      end
    end
  end

  describe "DELETE #destroy" do
    # before { sign_in user }

    it "問題が削除される" do
    end

    it "問題一覧ページにリダイレクトされる" do
    end

    context "他のユーザーの問題の場合" do
      it "削除できない" do
      end
    end
  end

  describe "GET #search_tag" do
    it "タグ検索が正常に動作する" do
    end

    context "ログインしていないユーザー" do
      it "タグ検索を利用できる" do
      end
    end
  end
end
