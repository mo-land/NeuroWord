import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // モーダルをbody直下に移動して参照を保持
    if (this.hasModalTarget) {
      this.modal = this.modalTarget
      document.body.appendChild(this.modal)
    }
  }

  disconnect() {
    // コントローラーが削除される時にモーダルも削除
    if (this.modal && this.modal.parentNode === document.body) {
      this.modal.remove()
    }
  }

  open() {
    if (this.modal) {
      this.modal.showModal()
    }
  }
}
