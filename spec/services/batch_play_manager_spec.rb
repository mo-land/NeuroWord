require 'rails_helper'

RSpec.describe BatchPlayManager do
  let(:session) { {} }
  let(:manager) { described_class.new(session) }
  let(:question) { create(:question) }

  describe '#active?' do
    context 'バッチプレイモードがONの場合' do
      before { session[:batch_play_mode] = true }

      it 'trueを返す' do
        expect(manager.active?).to be true
      end
    end

    context 'バッチプレイモードがOFFの場合' do
      it 'falseを返す' do
        expect(manager.active?).to be false
      end
    end

    context 'バッチプレイモードがnilの場合' do
      before { session[:batch_play_mode] = nil }

      it 'falseを返す' do
        expect(manager.active?).to be false
      end
    end
  end

  describe '#includes_question?' do
    before { session[:batch_play_question_ids] = [ 1, 2, 3 ] }

    it 'リストに含まれる問題IDに対してtrueを返す' do
      expect(manager.includes_question?(1)).to be true
    end

    it 'リストに含まれない問題IDに対してfalseを返す' do
      expect(manager.includes_question?(99)).to be false
    end

    context 'セッションにIDリストがない場合' do
      before { session.delete(:batch_play_question_ids) }

      it 'falseを返す' do
        expect(manager.includes_question?(1)).to be false
      end
    end
  end

  describe '#should_clear?' do
    context 'バッチプレイモードがOFFの場合' do
      it 'falseを返す' do
        expect(manager.should_clear?(question, '/mypage?tab=user_lists')).to be false
      end
    end

    context 'バッチプレイモードがONの場合' do
      before do
        session[:batch_play_mode] = true
        session[:batch_play_question_ids] = [ question.id ]
      end

      context '問題がリストに含まれず' do
        let(:other_question) { create(:question) }

        it 'trueを返す' do
          expect(manager.should_clear?(other_question, '/mypage?tab=user_lists')).to be true
        end
      end

      context '問題がリストに含まれ、マイページのリストタブからの遷移の場合' do
        it 'falseを返す' do
          expect(manager.should_clear?(question, 'http://example.com/mypage?tab=user_lists')).to be false
        end
      end

      context '問題がリストに含まれ、ゲーム画面からの遷移の場合' do
        it 'falseを返す' do
          expect(manager.should_clear?(question, 'http://example.com/games/123')).to be false
        end
      end

      context '問題がリストに含まれるが、不正な遷移元の場合' do
        it 'trueを返す' do
          expect(manager.should_clear?(question, 'http://example.com/questions/123')).to be true
        end
      end

      context 'refererがnilの場合' do
        it 'trueを返す' do
          expect(manager.should_clear?(question, nil)).to be true
        end
      end
    end
  end

  describe '#progress_info' do
    context 'バッチプレイモードがOFFの場合' do
      it 'nilを返す' do
        expect(manager.progress_info).to be_nil
      end
    end

    context 'バッチプレイモードがONの場合' do
      let(:list) { create(:list, user: create(:user), name: 'テストリスト') }

      before do
        session[:batch_play_mode] = true
        session[:batch_play_question_ids] = [ 1, 2, 3 ]
        session[:batch_play_current_index] = 1
        session[:batch_play_list_id] = list.id
      end

      it 'activeがtrueのハッシュを返す' do
        expect(manager.progress_info[:active]).to be true
      end

      it '正しい進行状況文字列を返す' do
        expect(manager.progress_info[:progress]).to eq('2 / 3')
      end

      it '対応するリストを返す' do
        expect(manager.progress_info[:list]).to eq(list)
      end

      context 'current_indexがセッションにない場合' do
        before { session.delete(:batch_play_current_index) }

        it '1問目として進行状況を返す' do
          expect(manager.progress_info[:progress]).to eq('1 / 3')
        end
      end

      context 'list_idが存在しない場合' do
        before { session[:batch_play_list_id] = -1 }

        it 'listがnilを返す' do
          expect(manager.progress_info[:list]).to be_nil
        end
      end
    end
  end

  describe '#clear' do
    before do
      session[:batch_play_mode] = true
      session[:batch_play_question_ids] = [ 1, 2, 3 ]
      session[:batch_play_current_index] = 1
      session[:batch_play_results] = { '1' => true }
      session[:batch_play_list_id] = 5
    end

    it '全てのバッチプレイ関連セッションをクリアする' do
      manager.clear

      BatchPlayManager::BATCH_SESSION_KEYS.each do |key|
        expect(session[key]).to be_nil
      end
    end

    it 'バッチプレイ以外のセッションは残す' do
      session[:other_key] = 'other_value'
      manager.clear

      expect(session[:other_key]).to eq('other_value')
    end
  end

  describe '#start' do
    it 'まとめてプレイのセッションを初期化する' do
      manager.start([ 1, 2, 3 ], 99)

      expect(session[:batch_play_mode]).to be true
      expect(session[:batch_play_question_ids]).to eq([ 1, 2, 3 ])
      expect(session[:batch_play_current_index]).to eq(0)
      expect(session[:batch_play_results]).to eq([])
      expect(session[:batch_play_list_id]).to eq(99)
    end
  end

  describe '#advance' do
    it 'current_index をインクリメントする' do
      manager.start([ 1, 2, 3 ], 99)
      manager.advance

      expect(manager.current_index).to eq(1)
    end
  end

  describe '#all_completed?' do
    it '全問完了後は true を返す' do
      manager.start([ 1 ], 99)
      manager.advance

      expect(manager.all_completed?).to be true
    end
  end
end
