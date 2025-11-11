import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "editLink"]

  changeList() {
    const listId = this.selectTarget.value
    const url = new URL(window.location.href)
    url.searchParams.set("list_id", listId)
    url.searchParams.set("tab", "user_lists")

    // Turboを使ってページ遷移（同期的なタブ更新のため）
    window.Turbo.visit(url.toString())
  }
}
