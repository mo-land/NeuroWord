require 'rails_helper'

RSpec.describe "Questions", type: :system do
  before do
    driven_by(:rack_test)
  end
  
  describe "問題作成・編集機能" do
    context "問題作成時" do
      it "ログインユーザーが新しい問題を作成できる" do
        # ログイン → 問題作成ページ → タイトル・説明入力 → 保存 → 問題一覧で確認
      end

      it "タグを追加して問題を作成できる" do
        # ログイン → 問題作成 → タグ入力 → 保存 → タグが正しく表示される
      end
    end

    context "問題編集時" do
      it "既存の問題にタグを追加・削除できる" do
        # ログイン → 既存問題の編集 → タグ追加・削除 → 保存 → 変更確認
      end

      it "カードセット追加制限が正しく動作する" do
        # ログイン → 問題編集 → カード上限まで追加 → さらに追加時にエラー表示
      end
    end
  end

  describe "ゲーム開始判定" do
    context "ゲーム開始可能な問題" do
      it "カードが十分な問題でゲーム開始ボタンが表示される" do
        # ログイン → 問題一覧 → 有効な問題 → ゲーム開始ボタン表示確認
      end
    end

    context "ゲーム開始不可能な問題" do
      it "カード不足の問題でゲーム開始ボタンが無効になる" do
        # ログイン → 問題一覧 → カード不足問題 → ボタン無効状態確認
      end
    end
  end

  describe "ゲームプレイ時のカード表示" do
    context "ゲーム画面でのカード表示" do
      it "起点カードと関連語カードが正しく表示される" do
        # ログイン → ゲーム開始 → カード配置確認 → シャッフル確認
      end

      it "カード選択時の正解・不正解判定が正しく動作する" do
        # ログイン → ゲーム開始 → 正しい組み合わせ選択 → 正解表示
        # → 間違った組み合わせ選択 → 不正解表示
      end
    end
  end
end
