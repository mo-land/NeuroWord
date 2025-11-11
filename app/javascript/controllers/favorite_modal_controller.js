import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // Turbo Streamによる更新を監視（モーダル内のフォームのみ）
    this.boundHandleSubmitEnd = this.handleSubmitEnd.bind(this)
    if (this.hasModalTarget) {
      this.modalTarget.addEventListener('turbo:submit-end', this.boundHandleSubmitEnd, true)
    }
  }

  disconnect() {
    // モーダルが開いていれば閉じる
    if (this.hasModalTarget && this.modalTarget.open) {
      this.modalTarget.close()
    }
    // イベントリスナーのクリーンアップ
    if (this.boundHandleSubmitEnd && this.hasModalTarget) {
      this.modalTarget.removeEventListener('turbo:submit-end', this.boundHandleSubmitEnd, true)
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
      // Turbo Streamの更新を待ってからモーダルを閉じる
      setTimeout(() => {
        this.close()
      }, 100)
    }
  }
}
