require 'rails_helper'

RSpec.describe GameStateManager do
  let(:session) { {} }
  let(:manager) { described_class.new(session) }
  let(:question) { create(:question) }
  let(:game_data) { { relateds: Array.new(5) } }

  describe '#initialize_game' do
    it 'セッションにゲーム状態を初期化する' do
      manager.initialize_game(question, game_data)

      expect(session[:game_question_id]).to eq(question.id)
      expect(session[:correct_matches]).to eq([])
      expect(session[:total_required_matches]).to eq(5)
      expect(session[:total_clicks]).to eq(0)
      expect(session[:correct_clicks]).to eq(0)
    end
  end

  describe '#clear_game_state' do
    it '全てのゲーム関連セッションをクリアする' do
      manager.initialize_game(question, game_data)
      manager.clear_game_state

      expect(session[:game_question_id]).to be_nil
      expect(session[:correct_matches]).to be_nil
      expect(session[:total_clicks]).to be_nil
    end
  end

  describe '#add_correct_match' do
    it '正解マッチを記録する' do
      manager.initialize_game(question, game_data)
      manager.add_correct_match(1, 'word')

      expect(session[:correct_matches]).to include('1-word')
    end

    it '重複した正解は記録しない' do
      manager.initialize_game(question, game_data)
      manager.add_correct_match(1, 'word')
      manager.add_correct_match(1, 'word')

      expect(session[:correct_matches].count('1-word')).to eq(1)
    end
  end

  describe '#game_completed?' do
    it '全マッチが完了している場合trueを返す' do
      manager.initialize_game(question, game_data)
      5.times { |i| manager.add_correct_match(i, "word#{i}") }

      expect(manager.game_completed?).to be true
    end

    it 'マッチが不完全な場合falseを返す' do
      manager.initialize_game(question, game_data)
      manager.add_correct_match(1, 'word')

      expect(manager.game_completed?).to be false
    end
  end
end
