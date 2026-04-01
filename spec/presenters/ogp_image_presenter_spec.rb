require 'rails_helper'

RSpec.describe OgpImagePresenter do
  let(:question) { create(:question, title: "テストタイトル") }

  describe '#url' do
    context 'from が "creator" のとき' do
      it 'CREATOR_IMAGE_TEMPLATE に escaped_title が埋め込まれた URL を返す' do
        presenter = described_class.new(question, "creator")
        expected = format(OgpImagePresenter::CREATOR_IMAGE_TEMPLATE, "テストタイトル")
        expect(presenter.url).to eq(expected)
      end
    end

    context 'from が "result" のとき' do
      it 'RESULT_IMAGE_TEMPLATE に escaped_title が埋め込まれた URL を返す' do
        presenter = described_class.new(question, "result")
        expected = format(OgpImagePresenter::RESULT_IMAGE_TEMPLATE, "テストタイトル")
        expect(presenter.url).to eq(expected)
      end
    end

    context 'from が nil のとき' do
      it 'DEFAULT_IMAGE_URL を返す' do
        presenter = described_class.new(question, nil)
        expect(presenter.url).to eq(OgpImagePresenter::DEFAULT_IMAGE_URL)
      end
    end

    context 'from が想定外の値のとき' do
      it 'DEFAULT_IMAGE_URL を返す' do
        presenter = described_class.new(question, "unknown")
        expect(presenter.url).to eq(OgpImagePresenter::DEFAULT_IMAGE_URL)
      end
    end

    context 'タイトルに絵文字が含まれるとき' do
      let(:question) { create(:question, title: "テスト🎉タイトル") }

      it 'from が "creator" のとき、絵文字が除去された URL を返す' do
        presenter = described_class.new(question, "creator")
        expected = format(OgpImagePresenter::CREATOR_IMAGE_TEMPLATE, "テストタイトル")
        expect(presenter.url).to eq(expected)
      end
    end

    context 'タイトルに絵文字が含まれないとき' do
      let(:question) { create(:question, title: "普通のタイトル") }

      it 'from が "result" のとき、タイトルがそのまま URL に含まれる' do
        presenter = described_class.new(question, "result")
        expected = format(OgpImagePresenter::RESULT_IMAGE_TEMPLATE, "普通のタイトル")
        expect(presenter.url).to eq(expected)
      end
    end
  end
end
