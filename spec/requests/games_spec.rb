require 'rails_helper'

RSpec.describe "Games", type: :request do
  # let(:user) { create(:user) }
  # let(:question) { create(:question, :with_card_sets, user: user) }

  describe "GET #show" do
    context "ゲーム開始可能な問題の場合" do
      it "ゲーム画面が正常に表示される" do
      end

      it "ゲームセッションが初期化される" do
      end

      it "OGP画像が動的に設定される" do
      end
    end

    context "ゲーム開始不可能な問題の場合" do
      it "問題詳細ページにリダイレクトされる" do
      end

      it "適切なアラートメッセージが表示される" do
      end
    end

    context "存在しない問題の場合" do
      it "404エラーが返される" do
      end
    end
  end

  describe "POST #check_match" do
    # before do
    #   # ゲームセッション初期化
    # end

    context "起点カード選択時" do
      it "起点カードがセッションに保存される" do
      end

      it "適切なJSONレスポンスが返される" do
      end
    end

    context "関連語カード選択時（正解）" do
      it "正解として処理される" do
      end

      it "セッションが正しく更新される" do
      end

      it "スコアが記録される" do
      end
    end

    context "関連語カード選択時（不正解）" do
      it "不正解として処理される" do
      end

      it "適切なエラーレスポンスが返される" do
      end
    end

    context "ゲーム完了時" do
      it "ゲーム記録が保存される" do
      end

      it "完了フラグが設定される" do
      end
    end

    context "無効なリクエスト" do
      it "適切にエラーハンドリングされる" do
      end
    end
  end

  describe "セッション管理" do
    context "新しいゲーム開始時" do
      it "既存のセッションがクリアされる" do
      end
    end

    context "ゲーム中断・再開時" do
      it "セッション状態が維持される" do
      end
    end
  end
end
