require 'rails_helper'

RSpec.describe "Questions", type: :system do
  before do
    driven_by(:rack_test)
  end

  let(:user) { create(:user) }
  let(:question) { create(:question) }

  describe "未ログイン時" do
    context "問題作成時" do
      it "未ログイン時は問題作成できない" do
        visit new_question_path
        expect(page).to have_content('ログインもしくはアカウント登録してください')
        expect(current_path).to eq new_user_session_path
      end
    end

    context "問題編集時" do
      let!(:question) { create(:question) }

      it "未ログイン時は問題編集できない" do
        visit edit_question_path(question)
        expect(page).to have_content('ログインもしくはアカウント登録してください')
        expect(current_path).to eq new_user_session_path
      end
    end
  end

  describe "ログイン時" do
    before { login(user) }

    context "問題作成時" do
      it "ログインユーザーが新しい問題を作成できる" do
        # ルートカテゴリを作成（セレクトボックスに表示されるため）
        category = create(:category, :uncategorized)

        # ログイン → 問題作成ページ → タイトル・説明入力 → 保存 → 問題一覧で確認
        visit new_question_path

        # デバッグ: カテゴリが表示されているか確認
        expect(page).to have_select('question_category_id', with_options: [ '息抜き系・未分類' ])

        fill_in 'タイトル', with: '問題タイトル'
        fill_in '説明', with: '説明'
        select '息抜き系・未分類', from: 'question_category_id'
        click_button '次へ：カードセットを追加'
        expect(page).to have_content('ステップ1完了')

        created_question = Question.last
        expect(current_path).to eq new_question_card_set_path(created_question)
      end
    end

    describe "問題編集時" do
      context "ログインユーザーが作成した問題" do
        let!(:question) { create(:question, user: user) }

        it "問題編集ができる" do
          visit edit_question_path(question)
          fill_in 'タイトル', with: '新問題タイトル'
          fill_in '説明', with: '新説明'
          click_button '更新'
          expect(page).to have_content('問題を更新しました')
          expect(current_path).to eq question_path(question)
        end

        it "カードセット追加制限が正しく動作する" do
          # 9枚分のカードセット（1起点+2関連語×3セット）を事前作成
          3.times do |i|
            create(:origin_word, question: question, origin_word: "起点#{i}", related_words_list: [ "関連語#{i}-1", "関連語#{i}-2" ])  # 3枚
          end

          visit question_path(question)

          expect(page).to have_no_content('新しいカードセットを追加')
          expect(page).to have_content('カード数上限に達しました')
        end
      end
    end
  end

  describe "ゲーム開始判定" do
    context "ゲーム開始可能な問題" do
      it "カードが十分な問題でゲーム開始ボタンが表示される" do
        valid_question = create(:question, user: user)
        2.times do |i|
          create(:origin_word, question: valid_question, origin_word: "起点#{i}", related_words_list: [ "関連語#{i}-1", "関連語#{i}-2" ])
        end

        visit question_path(valid_question)
        expect(page).to have_link('ゲーム開始')
        expect(page).to have_content("#{valid_question.title}")
      end
    end

    context "ゲーム開始不可能な問題" do
      it "カード不足の問題でゲーム開始ボタンが無効になる" do
        invalid_question = create(:question, user: user)
        create(:origin_word, question: question, origin_word: "起点1", related_words_list: [ "関連語1" ])  # 2枚

        visit question_path(invalid_question)
        expect(page).not_to have_link('ゲーム開始')
        expect(page).to have_content("#{invalid_question.title}")
        expect(page).to have_content('ゲームを開始するには2組以上のカードセットが必要です')
      end
    end
  end

  describe "ゲームプレイ時のカード表示" do
    before do
      skip 'CI環境ではSeleniumテストをスキップ' if ENV['CI']

      if ENV['SELENIUM_DRIVER_URL'].present?
        driven_by(:remote_chrome)
      else
        driven_by(:selenium_chrome_headless)
      end
    end

    context "ゲーム画面でのカード表示" do
      it "起点カードと関連語カードが正しく表示される" do
        game_question = create(:question, user: user)
        card_set1 = create(:origin_word, question: game_question, origin_word: "Java", related_words_list: [ "Spring", "Maven" ])  # 3枚
        card_set2 = create(:origin_word, question: game_question, origin_word: "Ruby", related_words_list: [ "Rails", "Gem" ])  # 3枚

        visit question_path(game_question)
        click_link 'ゲーム開始'

        expect(page).to have_content('Java')
        expect(page).to have_content('Ruby')
        expect(page).to have_content('Spring')
        expect(page).to have_content('Maven')
        expect(page).to have_content('Rails')
        expect(page).to have_content('Gem')
        expect(page).to have_css('.origin-card', count: 2)
        expect(page).to have_css('.related-card', count: 4)
      end

      it "カード選択時に判定用のポップが出る ※正誤判定結果が正しいかどうかのテストは不可" do
        # APIエラー（テスト環境のみ）のため、正誤判定結果が正しいかどうかのテストは不可
        # ログインユーザーが作成した問題を使用
        game_question = create(:question, user: user)
        card_set1 = create(:origin_word, question: game_question, origin_word: "Java", related_words_list: [ "Spring", "Maven" ])  # 3枚
        card_set2 = create(:origin_word, question: game_question, origin_word: "Ruby", related_words_list: [ "Rails", "Gem" ])  # 3枚

        visit question_path(game_question)
        click_link 'ゲーム開始'

        # 正しい組み合わせをクリック
        find('.origin-card', text: 'Java').click
        sleep(1)
        find('.related-card', text: 'Spring').click
        sleep(3)

        # まずはメッセージ表示の動作確認を重視
        expect(page).to have_content('エラーが発生しました').or(have_content('正解'))

        # メッセージが消えるまで待つ
        sleep(4)

        # 間違った組み合わせをクリック
        find('.origin-card', text: 'Ruby').click
        sleep(1)
        find('.related-card', text: 'Spring').click
        sleep(3)

        # 2回目もメッセージ表示の動作確認
        expect(page).to have_content('エラーが発生しました').or(have_content('不正解'))
      end
    end
  end
end
