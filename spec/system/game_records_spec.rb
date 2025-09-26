require 'rails_helper'

RSpec.describe "GameRecords", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "レコード作成・更新のテスト" do
    context "ゲーム完了時" do
      it "ゲームを最後まで完了すると記録が保存される" do
        # ユーザーログイン → 問題選択 → ゲーム開始 → 全問正解 → 結果表示 → 記録確認
      end

      it "途中で間違えても最終的に完了すれば記録が保存される" do
        # ユーザーログイン → ゲーム開始 → 一部不正解 → 完了 → 正答率記録確認
      end
    end

    context "記録更新時" do
      it "より良いスコアでゲームを完了すると記録が更新される" do
        # 初回プレイ → 記録保存 → 再プレイでより良いスコア → 記録更新確認
      end

      it "同じ問題を再プレイすると最新の記録で更新される" do
        # 初回プレイ → 再プレイ → 最新記録の確認
      end
    end

    context "ゲームプレイ統合テスト" do
      it "ログインからゲーム完了まで一連の流れで記録が正しく保存される" do
        # ログイン → 問題一覧 → 問題選択 → ゲーム画面 → カード選択 → 結果画面 → マイページで記録確認
      end
    end
  end
end
