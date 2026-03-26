require 'rails_helper'

RSpec.describe MatchCardCommand do
  let(:question) { create(:question) }
  let(:origin_word) { create(:origin_word, question: question, related_words_list: [ '正解ワード' ]) }
  let(:game_state) { instance_double(GameStateManager) }
  let(:command) { described_class.new(question: question, game_state: game_state, params: params) }

  describe '#call' do
    context 'SELECT_RELATED状態でない場合' do
      let(:params) { { origin_set_id: nil, related_word: '正解ワード', clicked_set_id: '1', current_state: 'SELECT_ORIGIN' } }

      it 'valid_action: falseを返す' do
        result = command.call
        expect(result.valid_action).to be false
        expect(result.message).to eq('まず起点カードを選択してください')
      end
    end

    context 'SELECT_RELATED状態の場合' do
      context '正しいマッチの場合' do
        let(:params) do
          { origin_set_id: origin_word.id.to_s, related_word: '正解ワード',
            clicked_set_id: origin_word.id.to_s, current_state: 'SELECT_RELATED' }
        end

        before do
          allow(game_state).to receive(:add_correct_match)
          allow(game_state).to receive(:increment_correct_clicks)
          allow(game_state).to receive(:game_completed?).and_return(false)
        end

        it 'valid_action: true、correct: trueを返す' do
          result = command.call
          expect(result.valid_action).to be true
          expect(result.correct).to be true
          expect(result.message).to eq('正解！')
        end

        it 'game_stateに正解を記録する' do
          expect(game_state).to receive(:add_correct_match).with(origin_word.id, '正解ワード')
          expect(game_state).to receive(:increment_correct_clicks)
          command.call
        end
      end

      context 'セットIDが一致しない場合' do
        let(:other_origin_word) { create(:origin_word, question: question, origin_word: '別の起点語') }
        let(:params) do
          { origin_set_id: origin_word.id.to_s, related_word: '正解ワード',
            clicked_set_id: other_origin_word.id.to_s, current_state: 'SELECT_RELATED' }
        end

        it 'valid_action: true、correct: falseを返す' do
          result = command.call
          expect(result.valid_action).to be true
          expect(result.correct).to be false
          expect(result.message).to eq('選択したカードは、現在の起点カードとセットになっていません')
        end
      end

      context 'related_wordが不一致の場合' do
        let(:params) do
          { origin_set_id: origin_word.id.to_s, related_word: '不正解ワード',
            clicked_set_id: origin_word.id.to_s, current_state: 'SELECT_RELATED' }
        end

        it 'valid_action: true、correct: falseを返す' do
          result = command.call
          expect(result.valid_action).to be true
          expect(result.correct).to be false
          expect(result.message).to eq('不正解...')
        end
      end
    end
  end
end
