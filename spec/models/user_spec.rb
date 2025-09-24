require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    context 'nameフィールドのテスト' do
      it 'nameが存在しない場合は無効である' do
      end

      it 'nameが空文字の場合は無効である' do
      end

      it 'nameが20文字以下の場合は有効である' do
      end

      it 'nameが21文字以上の場合は無効である' do
      end
    end

    context 'Deviseのバリデーション' do
      it 'メールアドレスが有効な形式の場合は有効である' do
      end

      it 'メールアドレスが無効な形式の場合は無効である' do
      end

      it 'パスワードが6文字以上で設定されている場合は有効である' do
      end
    end
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

  describe 'アソシエーションのテスト' do
    context 'questionsとの関係' do
      it '複数のquestionsを持つことができる' do
      end

      it 'ユーザー削除時にquestionsも削除される' do
      end
    end

    context 'game_recordsとの関係' do
      it '複数のgame_recordsを持つことができる' do
      end

      it 'ユーザー削除時にgame_recordsも削除される' do
      end
    end

    context 'requestsとの関係' do
      it '複数のrequestsを持つことができる' do
      end

      it 'ユーザー削除時にrequestsも削除される' do
      end
    end

    context 'request_responsesとの関係' do
      it '複数のrequest_responsesを持つことができる' do
      end

      it 'ユーザー削除時にrequest_responsesも削除される' do
      end
    end
  end

  describe '#own?' do
    context '自分が所有するオブジェクトの場合' do
      it 'trueを返す' do
      end
    end

    context '他人が所有するオブジェクトの場合' do
      it 'falseを返す' do
      end
    end

    context 'オブジェクトがnilの場合' do
      it 'falseを返す' do
      end
    end
  end
end
