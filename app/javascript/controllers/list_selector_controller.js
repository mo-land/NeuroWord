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

    // 編集リンクのURLを更新と表示/非表示を切り替え
    if (this.hasEditLinkTarget) {
      const selectedOption = this.selectTarget.selectedOptions[0]
      const isFavorite = selectedOption.dataset.isFavorite === "true"

      this.editLinkTarget.href = `/lists/${listId}/edit`

      if (isFavorite) {
        this.editLinkTarget.classList.add("!hidden")
      } else {
        this.editLinkTarget.classList.remove("!hidden")
      }
    }
  }
}
