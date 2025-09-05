import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    // オートコンプリートの結果リストをクリックしたときのイベントリスナー
    this.element.addEventListener('click', (event) => {
      const listItem = event.target.closest('li[data-question-id]')
      if (listItem) {
        const questionId = listItem.dataset.questionId
        const hiddenField = document.getElementById('request_question_id')
        if (hiddenField) {
          hiddenField.value = questionId
        }
      }
    })
  }

  disconnect() {
    // クリーンアップ処理
  }
}