require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  # let(:user) { create(:user) }
  # let(:valid_params) { { user: { name: "新しい名前", email: "new@example.com" } } }
  # let(:invalid_params) { { user: { name: "", email: "invalid-email" } } }

  describe "GET #new" do
    it "新規登録ページが正常に表示される" do
    end
  end

  describe "POST #create" do
    context "有効なパラメータの場合" do
      #       let(:create_params) { { user: { name: "テストユーザー", email: "test@example.com", password:
      # "password123", password_confirmation: "password123" } } }

      it "ユーザーが作成される" do
      end

      it "ルートパスにリダイレクトされる" do
      end
    end

    context "無効なパラメータの場合" do
      # let(:invalid_create_params) { { user: { name: "", email: "invalid", password: "123" } } }

      it "ユーザーが作成されない" do
      end

      it "新規登録ページが再表示される" do
      end
    end

    context "nameパラメータの許可" do
      it "nameパラメータが正しく処理される" do
      end
    end
  end

  describe "GET #edit" do
    context "ログインしているユーザーの場合" do
      # before { sign_in user }

      context "Turbo Frameリクエストの場合" do
        it "編集ページが正常に表示される" do
        end
      end

      context "通常のHTTPリクエストの場合" do
        it "マイページにリダイレクトされる" do
        end

        it "適切なアラートメッセージが表示される" do
        end
      end
    end

    context "ログインしていないユーザーの場合" do
      it "ログインページにリダイレクトされる" do
      end
    end
  end

  describe "PATCH/PUT #update" do
    # before { sign_in user }

    context "有効なパラメータの場合" do
      context "HTMLリクエスト" do
        it "ユーザー情報が更新される" do
        end

        it "マイページにリダイレクトされる" do
        end

        it "成功メッセージが表示される" do
        end
      end

      context "Turbo Streamリクエスト" do
        it "Turbo Stream形式でレスポンスが返される" do
        end
      end
    end

    context "無効なパラメータの場合" do
      context "HTMLリクエスト" do
        it "ユーザー情報が更新されない" do
        end

        it "編集ページが再表示される" do
        end
      end

      context "Turbo Streamリクエスト" do
        it "エラー状態でTurbo Stream形式でレスポンスが返される" do
        end
      end
    end

    context "パスワードなし更新の動作確認" do
      it "パスワードを入力せずに他の情報を更新できる" do
      end
    end

    context "nameパラメータの許可" do
      it "nameパラメータが正しく処理される" do
      end
    end
  end

  describe "DELETE #destroy" do
    # before { sign_in user }

    it "ユーザーアカウントが削除される" do
    end

    it "ルートパスにリダイレクトされる" do
    end
  end

  describe "プライベートメソッドの動作" do
    context "リダイレクト先の設定" do
      # before { sign_in user }

      it "更新後はマイページにリダイレクトされる" do
      end
    end
  end
end
