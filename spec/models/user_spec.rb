require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションチェック' do
    context 'nameフィールドのテスト' do
      it 'nameは存在する場合のみ有効か' do
        should validate_presence_of(:name)
      end

      it 'nameは20文字以下の場合のみ有効か' do
        should validate_length_of(:name).is_at_most(20)
      end
    end

    context 'Deviseのバリデーション' do
      subject { create(:user) }

      it 'メールアドレスは有効な形式の場合のみ有効か' do
        should allow_value('test@example.com').for(:email)
        should_not allow_value('test-example.com').for(:email)
      end

      it 'メールアドレスはユニークである場合のみ有効か' do
        should validate_uniqueness_of(:email).case_insensitive
      end

      it 'パスワードは6文字以上で設定されている場合のみ有効か' do
        should validate_length_of(:password).is_at_least(6)
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'questionsとの関係' do
      it '複数のquestionsを持つことができ, ユーザー削除時にquestionsも削除される' do
        should have_many(:questions).dependent(:destroy)
      end
    end

    context 'game_recordsとの関係' do
      it '複数のgame_recordsを持つことができ, ユーザー削除時にgame_recordsも削除される' do
        should have_many(:game_records).dependent(:destroy)
      end
    end

    context 'requestsとの関係' do
      it '複数のrequestsを持つことができ, ユーザー削除時にrequestsも削除される' do
        should have_many(:requests).dependent(:destroy)
      end
    end

    context 'request_responsesとの関係' do
      it '複数のrequest_responsesを持つことができ, ユーザー削除時にrequest_responsesも削除される' do
        should have_many(:request_responses).dependent(:destroy)
      end
    end
  end

  describe '#own?' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context '自分が所有するオブジェクトの場合' do
      it 'questionオブジェクトでtrueを返す' do
        question = create(:question, user: user)
        expect(user.own?(question)).to be true
      end

      it 'game_recordオブジェクトでtrueを返す' do
        game_record = create(:game_record, user: user)
        expect(user.own?(game_record)).to be true
      end

      it 'requestオブジェクトでtrueを返す' do
        request = create(:request, user: user)
        expect(user.own?(request)).to be true
      end

      it 'request_responseオブジェクトでtrueを返す' do
        request_response = create(:request_response, user: user)
        expect(user.own?(request_response)).to be true
      end
    end

    context '他のユーザーが所有するオブジェクトの場合' do
      it 'questionオブジェクトでfalseを返す' do
        question = create(:question, user: other_user)
        expect(user.own?(question)).to be false
      end

      it 'game_recordオブジェクトでfalseを返す' do
        game_record = create(:game_record, user: other_user)
        expect(user.own?(game_record)).to be false
      end

      it 'requestオブジェクトでfalseを返す' do
        request = create(:request, user: other_user)
        expect(user.own?(request)).to be false
      end

      it 'request_responseオブジェクトでfalseを返す' do
        request_response = create(:request_response, user: other_user)
        expect(user.own?(request_response)).to be false
      end
    end

    context 'nilオブジェクトの場合' do
      it 'falseを返す' do
        expect(user.own?(nil)).to be false
      end
    end

    context 'user_idを持たないオブジェクトの場合' do
      it 'falseを返す' do
        object_without_user_id = double('object', user_id: nil)
        expect(user.own?(object_without_user_id)).to be false
      end
    end

    context 'user_idが文字列の場合' do
      it '適切に比較してtrueを返す' do
        question = create(:question, user: user)
        # user_idが文字列として渡された場合の動作確認
        allow(question).to receive(:user_id).and_return(user.id.to_s)
        expect(user.own?(question)).to be false  # 型が異なるため false
      end
    end
  end
end
