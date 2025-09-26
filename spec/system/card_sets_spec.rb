require 'rails_helper'

RSpec.describe "CardSets", type: :system do
  before do
    driven_by(:rack_test)
  end

   describe "カードセット作成・編集機能" do
    context "カードセット作成時" do
      it "問題にカードセットを追加できる" do
        # ログイン → 問題編集 → カードセット追加フォーム → 起点語・関連語入力 → 保存
      end

      it "関連語を複数追加してカードセットを作成できる" do
        # ログイン → カードセット作成 → 関連語複数入力 → 保存 → 表示確認
      end
    end

    context "カードセット編集時" do
      it "既存のカードセットを編集できる" do
        # ログイン → 問題編集 → 既存カードセット選択 → 内容変更 → 保存
      end

      it "関連語を追加・削除できる" do
        # ログイン → カードセット編集 → 関連語追加・削除 → 保存 → 変更確認
      end
    end
  end

  describe "ゲーム中のカード動作" do
    context "カード表示・選択機能" do
      it "ゲーム画面でカードが正しく表示される" do
        # ログイン → ゲーム開始 → 起点カード・関連語カード表示確認
      end

      it "カード選択時のマッチング判定が正しく動作する" do
        # ログイン → ゲーム開始 → 正しいペア選択 → マッチング成功
        # → 間違ったペア選択 → マッチング失敗
      end

      it "全てのカードがマッチすると完了画面に遷移する" do
        # ログイン → ゲーム開始 → 全ペア正解 → 完了画面表示
      end
    end
  end

  describe "カードセット制限機能" do
    context "カード数制限" do
      it "カード総数上限時に追加制限が正しく動作する" do
        # ログイン → 問題編集 → カード上限まで追加 → 追加ボタン無効化確認
      end
    end
  end
end
