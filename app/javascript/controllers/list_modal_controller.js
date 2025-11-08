import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "frame"]

  closeModal() {
    this.dialogTarget.close()
  }

  resetFrame() {
    // モーダルを閉じた後、フレームをリセットして次回開いた時に新しいフォームを読み込む
    this.frameTarget.src = this.frameTarget.getAttribute("src")
  }

  // フォーム送信成功後に呼ばれる (turbo:submit-endイベント経由)
  handleSubmitEnd(event) {
    // 成功した場合のみモーダルを閉じる
    if (event.detail.success) {
      this.closeModal()
      // 少し遅延させてからフレームをリセット
      setTimeout(() => this.resetFrame(), 300)
    }
  }
}
