require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:valid_params) { { question: { title: "テスト問題", description: "説明" } } }
  let(:invalid_params) { { question: { title: "", description: "" } } }

  describe "GET #index" do
    context "ログインしていないユーザー" do
      it "問題一覧を閲覧できる" do
        get questions_path
        expect(response).to have_http_status(200)
      end

      it "編集・削除ボタンが表示されない" do
        other_user = create(:user)
        question = create(:question, user: other_user)
        get questions_path
        expect(response.body).not_to include("button-edit-#{question.id}")
        expect(response.body).not_to include("button-delete-#{question.id}")
      end

      xit "タグ一覧が表示される" do
      end
    end

    context "ログインしているユーザー" do
      before { sign_in user }

      it "問題一覧が正常に表示される" do
        get questions_path
        expect(response).to have_http_status(200)
      end

      it "自分の問題には編集・削除ボタンが表示される" do
        my_question = create(:question, user: user)
        get questions_path
        expect(response.body).to include("button-edit-#{my_question.id}")
        expect(response.body).to include("button-delete-#{my_question.id}")
      end

      it "問題作成ボタンが表示される" do
        get questions_path
        expect(response.body).to include(new_question_path)
      end
    end
  end

  describe "GET #show" do
    it "問題詳細ページが正常に表示される" do
      get question_path(question)
      expect(response).to have_http_status(200)
    end

    context "ログインしていないユーザー" do
      it "問題詳細を閲覧できる" do
        get question_path(question)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET #new" do
    context "ログインしているユーザー" do
      before { sign_in user }

      it "新規作成ページが正常に表示される" do
        get new_question_path
        expect(response).to have_http_status(200)
      end
    end

    context "ログインしていないユーザー" do
      it "ログインページにリダイレクトされる" do
        get new_question_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #create" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      it "問題が作成される" do
        expect {
          post questions_path, params: valid_params
        }.to change(Question, :count).by(1)
      end

      it "カードセット作成ページにリダイレクトされる" do
        post questions_path, params: valid_params
        expect(response).to have_http_status(302)
        created_question = Question.last
        expect(response).to redirect_to(new_question_card_set_path(created_question))
      end

      xit "タグが正しく処理される" do
      end
    end

    context "無効なパラメータの場合" do
      it "問題が作成されない" do
        expect {
          post questions_path, params: invalid_params
        }.not_to change(Question, :count)
      end

      it "新規作成ページが再表示される" do
        post questions_path, params: invalid_params
        expect(response).to have_http_status(422)
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
    before { sign_in user }
    let!(:question) { create(:question, user: user) }

    it "編集ページが正常に表示される" do
      get edit_question_path(question)
      expect(response).to have_http_status(200)
    end

    context "他のユーザーの問題の場合" do
      let!(:other_user) { create(:user) }  # 別のユーザーを作成
      let!(:other_question) { create(:question, user: other_user) }  # 別のユーザーの問題を作成

      it "404エラーが返される" do
        get edit_question_path(other_question)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH/PUT #update" do
    before { sign_in user }
    let!(:my_question) { create(:question, user: user, title: "元のタイトル") }

    context "有効なパラメータの場合" do
      it "問題が更新される" do
        patch question_path(my_question), params: { question: { title: "更新されたタイトル" } }
        my_question.reload
        expect(my_question.title).to eq("更新されたタイトル")
      end

      it "問題詳細ページにリダイレクトされる" do
        patch question_path(my_question), params: valid_params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(question_path(my_question))
      end

      it "タグが更新される" do
        # タグ機能のテストは実装時に追記
      end
    end

    context "無効なパラメータの場合" do
      it "問題が更新されない" do
        original_title = my_question.title
        patch question_path(my_question), params: invalid_params
        my_question.reload
        expect(my_question.title).to eq(original_title)
      end

      it "編集ページが再表示される" do
        patch question_path(my_question), params: invalid_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in user }
    let!(:my_question) { create(:question, user: user) }

    it "問題が削除される" do
      expect {
        delete question_path(my_question)
      }.to change(Question, :count).by(-1)
    end

    it "問題一覧ページにリダイレクトされる" do
      delete question_path(my_question)
      expect(response).to have_http_status(303)
      expect(response).to redirect_to(questions_path)
    end

    context "他のユーザーの問題の場合" do
      let!(:other_user) { create(:user) }
      let!(:other_question) { create(:question, user: other_user) }

      it "削除できない" do
        expect {
          delete question_path(other_question)
        }.not_to change(Question, :count)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "GET #search_tag" do
    xit "タグ検索が正常に動作する" do
    end

    context "ログインしていないユーザー" do
      xit "タグ検索を利用できる" do
      end
    end
  end
end
