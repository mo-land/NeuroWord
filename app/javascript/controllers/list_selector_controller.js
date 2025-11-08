import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "editLink"]

  changeList() {
    const listId = this.selectTarget.value
    const url = new URL(window.location.href)
    url.searchParams.set("list_id", listId)
    url.searchParams.set("tab", "user_lists")

    // Turbo Frameを使って非同期で問題一覧を更新
    const frame = document.getElementById("list_questions")
    frame.src = url.toString()
    frame.reload()

    // 編集ボタンの表示/非表示を切り替えとTurbo Frameのsrcを更新
    if (this.hasEditLinkTarget) {
      const selectedOption = this.selectTarget.selectedOptions[0]
      const isFavorite = selectedOption.dataset.isFavorite === "true"

      // 編集ボタンの親要素（モーダル全体）を取得
      const editModalContainer = this.editLinkTarget.closest('[data-controller="list-modal"]')

      // Turbo Frameのsrcを更新
      const editFrame = editModalContainer.querySelector('[data-list-modal-target="frame"]')
      if (editFrame) {
        editFrame.src = `/lists/${listId}/edit`
      }

      if (isFavorite) {
        editModalContainer.classList.add("hidden")
      } else {
        editModalContainer.classList.remove("hidden")
      }
    }
  }
}
