require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'Deviseの認証機能' do
    context 'ユーザー登録' do
      it '有効な情報でユーザーを作成できる' do
      end

      it '重複するメールアドレスでは作成できない' do
      end
    end

    context 'ログイン機能' do
      it '正しい認証情報でログインできる' do
      end

      it '間違った認証情報ではログインできない' do
      end
    end

    context 'パスワードリセット機能' do
      it 'パスワードリセットトークンが生成される' do
      end

      it '有効なトークンでパスワードを変更できる' do
      end
    end
  end
end
