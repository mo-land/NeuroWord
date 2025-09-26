require 'rails_helper'

RSpec.describe GameRecord, type: :model do
  describe "バリデーション" do
    context "total_matchesフィールドのテスト" do
      it "total_matchesが0以上の場合は有効である" do
      end

      it "total_matchesが0の場合は有効である" do
      end

      it "total_matchesが正の整数の場合は有効である" do
      end

      it "total_matchesが負の値の場合は無効である" do
      end

      it "total_matchesが文字列の場合は無効である" do
      end

      it "total_matchesが小数の場合は有効である" do
      end
    end

    context "accuracyフィールドのテスト" do
      it "accuracyが0の場合は有効である" do
      end

      it "accuracyが100の場合は有効である" do
      end

      it "accuracyが0〜100の範囲内の場合は有効である" do
      end

      it "accuracyが0未満の場合は無効である" do
      end

      it "accuracyが100を超える場合は無効である" do
      end

      it "accuracyが文字列の場合は無効である" do
      end

      it "accuracyが小数の場合は有効である" do
      end
    end

    context "completion_time_secondsフィールドのテスト" do
      it "completion_time_secondsが0以上の場合は有効である" do
      end

      it "completion_time_secondsが0の場合は有効である" do
      end

      it "completion_time_secondsが正の数値の場合は有効である" do
      end

      it "completion_time_secondsがnilの場合は有効である" do
      end

      it "completion_time_secondsが負の値の場合は無効である" do
      end

      it "completion_time_secondsが文字列の場合は無効である" do
      end

      it "completion_time_secondsが小数の場合は有効である" do
      end
    end
  end

  describe "アソシエーション" do
    context "userとの関係" do
      it "userに所属している" do
      end

      it "userが存在しない場合は無効である" do
      end

      it "有効なuserが関連付けられている場合は有効である" do
      end
    end

    context "questionとの関係" do
      it "questionに所属している" do
      end

      it "questionが存在しない場合は無効である" do
      end

      it "有効なquestionが関連付けられている場合は有効である" do
      end
    end
  end

  describe "データ型・形式のテスト" do
    context "無効なデータ型が入力された場合" do
      it "total_matchesに配列が入力された場合は無効である" do
      end

      it "total_matchesにハッシュが入力された場合は無効である" do
      end

      it "accuracyに配列が入力された場合は無効である" do
      end

      it "accuracyにハッシュが入力された場合は無効である" do
      end

      it "completion_time_secondsに配列が入力された場合は無効である" do
      end

      it "completion_time_secondsにハッシュが入力された場合は無効である" do
      end
    end

    context "小数点を含む数値での動作" do
      it "total_matchesに小数が入力された場合の動作を確認する" do
      end

      it "accuracyに小数が入力された場合の動作を確認する" do
      end

      it "completion_time_secondsに小数が入力された場合の動作を確認する" do
      end
    end
  end

  describe "エッジケース" do
    context "境界値での動作" do
      it "accuracyが境界値0で有効である" do
      end

      it "accuracyが境界値100で有効である" do
      end

      it "total_matchesが境界値0で有効である" do
      end

      it "completion_time_secondsが境界値0で有効である" do
      end
    end

    context "非常に大きな数値での動作" do
      it "total_matchesに非常に大きな数値が入力された場合も有効である" do
      end

      it "completion_time_secondsに非常に大きな数値が入力された場合も有効である" do
      end

      it "accuracyに非常に大きな数値が入力された場合は無効である" do
      end
    end

    context "必須フィールドが未入力の場合" do
      it "userが未設定の場合は無効である" do
      end

      it "questionが未設定の場合は無効である" do
      end

      it "total_matchesが未設定の場合の動作を確認する" do
      end

      it "accuracyが未設定の場合の動作を確認する" do
      end
    end
  end
end
