import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // Turbo Streamによる更新を監視
    this.boundHandleSubmitEnd = this.handleSubmitEnd.bind(this)
    document.addEventListener('turbo:submit-end', this.boundHandleSubmitEnd)
  }

  disconnect() {
    // モーダルが開いていれば閉じる
    if (this.hasModalTarget && this.modalTarget.open) {
      this.modalTarget.close()
    }
    // イベントリスナーのクリーンアップ
    if (this.boundHandleSubmitEnd) {
      document.removeEventListener('turbo:submit-end', this.boundHandleSubmitEnd)
    }
  }

  open() {
    if (this.hasModalTarget) {
      this.modalTarget.showModal()
    }
  }

  close() {
    if (this.hasModalTarget) {
      this.modalTarget.close()
    }
  }

  handleSubmitEnd(event) {
    // モーダル内のフォームからの送信かチェック
    const form = event.target
    const isModalForm = this.hasModalTarget && this.modalTarget.contains(form)

    if (isModalForm && event.detail.success) {
      // モーダルを即座に閉じる
      this.close()
    }
  }
}
