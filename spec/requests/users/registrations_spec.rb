require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:user) { create(:user) }

  describe "GET #new" do
    it "新規登録ページが正常に表示される" do
      get new_user_registration_path
      expect(response).to have_http_status(200)
    end
  end

  describe "POST #create" do
    context "有効なパラメータの場合" do
      let(:create_params) { { user: { name: "テストユーザー", email: "test@example.com", password: "password123", password_confirmation: "password123" } } }

      it "ユーザーが作成される" do
        expect {
          post user_registration_path, params: create_params
        }.to change(User, :count).by(1)
      end

      it "ルートパスにリダイレクトされる" do
        post user_registration_path, params: create_params
        expect(response).to redirect_to(root_path)
      end

      it "作成されたユーザーの情報が正しい" do
        post user_registration_path, params: create_params
        user = User.last
        expect(user.name).to eq("テストユーザー")
        expect(user.email).to eq("test@example.com")
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_create_params) { { user: { name: "", email: "invalid", password: "123" } } }

      it "ユーザーが作成されない" do
        expect {
          post user_registration_path, params: invalid_create_params
        }.to change(User, :count).by(0)
      end

      it "新規登録ページが再表示される" do
        post user_registration_path, params: invalid_create_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include '入力してください'
      end
    end

    context "nameパラメータの許可" do
      it "nameパラメータが正しく処理される" do
        post user_registration_path, params: { user: { name: "許可テスト", email: "param@example.com", password: "password123", password_confirmation: "password123" } }
        expect(User.last.name).to eq("許可テスト")
      end
    end
  end

  describe "GET #edit" do
    context "ログインしているユーザーの場合" do
      before { sign_in user }

      context "Turbo Frameリクエストの場合" do
        it "編集ページが正常に表示される" do
          get edit_user_registration_path, headers: { 'Turbo-Frame' => 'user-edit-form' }
          expect(response).to have_http_status(200)
          expect(response.body).to include('form')
        end
      end

      context "通常のHTTPリクエストの場合" do
        it "ユーザー編集ページにリダイレクトされる" do
          get edit_user_registration_path
          expect(response).to have_http_status(200)
        end
      end
    end

    context "ログインしていないユーザーの場合" do
      it "ログインページにリダイレクトされる" do
        get edit_user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH/PUT #update" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      let(:update_params) { { user: { name: "更新された名前" } } }

      context "HTMLリクエスト" do
        it "ユーザー情報が更新される" do
          patch user_registration_path, params: update_params
          user.reload
          expect(user.name).to eq("更新された名前")
        end

        it "マイページにリダイレクトされる" do
          patch user_registration_path, params: update_params
          expect(response).to redirect_to(mypage_path(user))
        end

        it "成功メッセージが表示される" do
          patch user_registration_path, params: update_params
          expect(flash[:notice]).to be_present
        end
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_update_params) { { user: { name: "", email: "invalid-email" } } }

      context "HTMLリクエスト" do
        it "ユーザー情報が更新されない" do
          original_name = user.name
          patch user_registration_path, params: invalid_update_params
          user.reload
          expect(user.name).to eq(original_name)
        end

        it "編集ページが再表示される" do
          patch user_registration_path, params: invalid_update_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include('form')
        end
      end
    end

    context "パスワードなし更新の動作確認" do
      it "パスワードを入力せずに他の情報を更新できる" do
        patch user_registration_path, params: { user: { name: "パスワードなし更新", email: user.email } }
        user.reload
        expect(user.name).to eq("パスワードなし更新")
        expect(response).to have_http_status(:see_other)
      end
    end

    context "nameパラメータの許可" do
      it "nameパラメータが正しく処理される" do
        patch user_registration_path, params: { user: { name: "許可されたname" } }
        user.reload
        expect(user.name).to eq("許可されたname")
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in user }

    it "ユーザーアカウントが削除される" do
      expect {
        delete user_registration_path
      }.to change(User, :count).by(-1)
    end

    it "ルートパスにリダイレクトされる" do
      delete user_registration_path
      expect(response).to redirect_to(root_path)
    end

    it "削除後はログアウト状態になる" do
      delete user_registration_path
      get mypage_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "プライベートメソッドの動作" do
    context "リダイレクト先の設定" do
      before { sign_in user }

      it "更新後はマイページにリダイレクトされる" do
        patch user_registration_path, params: { user: { name: "リダイレクトテスト" } }
        expect(response).to redirect_to(mypage_path(user))
      end

      it "sign_up後はルートパスにリダイレクトされる" do
        post user_registration_path, params: { user: { name: "新規ユーザー", email: "newuser@example.com", password: "password123", password_confirmation: "password123" } }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
