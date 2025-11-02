require 'rails_helper'

RSpec.describe "Users", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe 'Deviseの認証機能' do
    context 'ユーザー登録' do
      it '有効な情報でユーザーを作成できる' do
        visit new_user_registration_path
        fill_in 'ユーザー名', with: 'test_user'
        fill_in 'Eメール', with: 'test@example.com'
        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワード（確認用）', with: 'password123'
        click_button '登録'
        expect(page).to have_content('アカウント登録が完了しました。')
        expect(current_path).to eq root_path
      end

      it '重複するメールアドレスでは作成できない' do
        create(:user, email: 'test@example.com')
        visit new_user_registration_path
        fill_in 'Eメール', with: 'test@example.com'
        click_button '登録'
        expect(page).to have_content('登録できませんでした。入力内容をご確認ください')
      end

      it 'ユーザー名・アドレス未入力では登録できない' do
        visit new_user_registration_path
        fill_in 'ユーザー名', with: ''
        fill_in 'Eメール', with: ''
        click_button '登録'
        expect(page).to have_content('ユーザー名を入力してください')
        expect(page).to have_content('Eメールを入力してください')
      end

      it "Google認証が成功する" do
        visit new_user_registration_path
        click_button('Googleでログイン')
        expect(page).to have_content('Google アカウントによる認証に成功しました。')
      end
    end

    context 'ログイン機能' do
      let!(:user) { User.create(name: "username", email: "test@example.com", password: "password") }

      it '正しい認証情報でログインできる' do
        login(user)
        expect(page).to have_content "ログインしました"
      end

      it '間違った認証情報ではログインできない' do
        # ユーザー作成 → ログインページ → 間違った情報入力 → エラーメッセージ表示
        visit new_user_session_path
        fill_in 'Eメール', with: 'test@example.com'
        fill_in 'パスワード', with: 'wrong_password'
        click_button "ログイン"
        expect(page).to have_content "Eメールまたはパスワードが違います"
        expect(current_path).to eq new_user_session_path
      end

      it 'ログアウトが正しく動作する' do
        # ログイン → マイページ → ログアウトボタンクリック → トップページ遷移
        login(user)
        first(:link_or_button, 'ログアウト').click
        expect(current_path).to eq root_path
        expect(page).to have_content "ログアウトしました。"
        expect(current_path).to eq root_path
      end
    end

    context 'パスワードリセット機能' do
      xit 'パスワードリセットリンクを送信できる' do
        # ユーザー作成 → パスワードリセットページ → メール入力 → 送信完了メッセージ表示
      end

      xit '有効なトークンでパスワードを変更できる' do
        # パスワードリセット → トークン付きリンク → 新パスワード入力 → 変更完了
      end

      xit '無効なトークンではパスワード変更できない' do
        # 無効なトークンでアクセス → エラーメッセージ表示
      end
    end

    context 'アカウント管理' do
      let!(:user) { User.create(name: "username", email: "test@example.com", password: "password") }

      xit 'プロフィール情報を編集できる' do
        # ログイン → アカウント編集ページ → 情報変更 → 保存 → 変更内容反映確認
        # ↓が実行できないためスキップ
        # fill_in 'ユーザー名', with: 'newname'
      end

      xit 'アカウントを削除できる' do
        # ログイン → アカウント削除 → 確認画面 → 削除実行 → トップページ遷移
      end
    end
  end
end
