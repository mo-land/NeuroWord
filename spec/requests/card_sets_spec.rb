require 'rails_helper'

RSpec.describe "CardSets", type: :request do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:card_set) { create(:card_set, question: question) }
  let(:valid_params) { { card_set: { origin_word: "起点語", related_words: ["関連語1", "関連語2"]  } } }

  describe "GET #new" do
    before { sign_in user }

    it "新規作成ページが正常に表示される" do
      get new_question_card_set_path(question)
      expect(response).to have_http_status(200)
    end

    context "カード数上限の場合" do
      it "アラートメッセージと共にリダイレクトされる" do
        # 10枚のカードを作成して上限に到達
        create(:card_set, question: question, related_words: Array.new(9, "関連語"))
        get new_question_card_set_path(question)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(question_path(question))
      end
    end
    
    context "他のユーザーの問題の場合" do
      let(:other_user) { create(:user) }
      let(:other_question) { create(:question, user: other_user) }
      
      it "アクセスできない" do
        get new_question_card_set_path(other_question)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST #create" do
  before { sign_in user }
  
    describe "有効なパラメータの場合" do
      let(:create_card_set) { post question_card_sets_path(question), params: valid_params }
      let(:create_another_card_set) { post question_card_sets_path(question), params: valid_params }

      it "カードセットが作成される" do
        expect {
          create_card_set
        }.to change(CardSet, :count).by(1)
      end

      context "カードセットが1つの場合" do
        it "2つ目のカードセット追加を要求される" do
          create_card_set
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(new_question_card_set_path(question))
        end
      end

      context "カードセットが２つの場合" do
        it "問題詳細ページにリダイレクトされる" do
          create_card_set
          create_another_card_set
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(question_path(question))
        end
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) { { card_set: { origin_word: "", related_words: [] } } }

      it "カードセットが作成されない" do
        expect {
          post question_card_sets_path(question), params: invalid_params
        }.not_to change(CardSet, :count)
      end

      it "新規作成ページが再表示される" do
        post question_card_sets_path(question), params: invalid_params
        expect(response).to have_http_status(422)
      end
    end

    context "カード数制限チェック" do
      it "上限を超える場合は作成できない" do
        create(:card_set, question: question, related_words: Array.new(9, "関連語"))
        expect {
          post question_card_sets_path(question), params: valid_params
        }.not_to change(CardSet, :count)
      end
    end
  end

  describe "GET #edit" do
    before { sign_in user }

    it "編集ページが正常に表示される" do
      get edit_question_card_set_path(question, card_set)
      expect(response).to have_http_status(200)
    end

    context "他のユーザーのカードセット" do
      let(:other_user) { create(:user) }
      let(:other_question) { create(:question, user: other_user) }
      let(:other_card_set) { create(:card_set, question: other_question) }

      it "アクセスできない" do
        get edit_question_card_set_path(other_question, other_card_set)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH/PUT #update" do
    before { sign_in user }

    context "有効なパラメータの場合" do
      let(:update_params) { { card_set: { origin_word: "更新された起点語", related_words: ["更新関連語1", "更新関連語2"] } } }

      it "カードセットが更新される" do
        patch question_card_set_path(question, card_set), params: update_params
        card_set.reload
        expect(card_set.origin_word).to eq("更新された起点語")
        expect(card_set.related_words).to eq(["更新関連語1", "更新関連語2"])
      end

      it "問題詳細ページにリダイレクトされる" do
        patch question_card_set_path(question, card_set), params: update_params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(question_path(question))
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_update_params) { { card_set: { origin_word: "", related_words: [] } } }

      it "カードセットが更新されない" do
        original_origin_word = card_set.origin_word
        patch question_card_set_path(question, card_set), params: invalid_update_params
        card_set.reload
        expect(card_set.origin_word).to eq(original_origin_word)
      end

      it "編集ページが再表示される" do
        patch question_card_set_path(question, card_set), params: invalid_update_params
        expect(response).to have_http_status(422)
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in user }
    let!(:base_card_set_to_delete) { create(:card_set, question: question) }
    let!(:add1_card_set_to_delete) { create(:card_set, question: question) }
    let!(:add2_card_set_to_delete) { create(:card_set, question: question) }
    

    it "カードセットが削除される" do
      expect {
        delete question_card_set_path(question, add2_card_set_to_delete)
      }.to change(CardSet, :count).by(-1)
    end

    it "問題詳細ページにリダイレクトされる" do
      delete question_card_set_path(question, add2_card_set_to_delete)
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(question_path(question))
    end

    context "他のユーザーのカードセット" do
      let(:other_user) { create(:user) }
      let(:other_question) { create(:question, user: other_user) }
      let!(:other_card_set) { create(:card_set, question: other_question) }

      it "削除できない" do
        expect {
          delete question_card_set_path(other_question, other_card_set)
        }.not_to change(CardSet, :count)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
