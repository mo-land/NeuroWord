// app/javascript/controllers/game_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "originCard", 
    "relatedCard", 
    "score", 
    "timer", 
    "message", 
    "messageText",
    "completionModal",
    "finalScore",
    "finalTime"
  ]

  connect() {
    this.selectedOriginId = null
    this.selectedOriginCompleted = new Set() // 完了した起点カードのセットID
    this.correctMatches = 0
    this.totalMatches = parseInt(this.data.get("totalMatches"))
    this.questionId = this.data.get("questionId")
    this.startTime = Date.now()
    this.timerInterval = setInterval(() => this.updateTimer(), 1000)
    this.gameState = "SELECT_ORIGIN" // "SELECT_ORIGIN" or "SELECT_RELATED"
    
    // クリック数追跡用
    this.totalClicks = 0
    this.correctClicks = 0
    
    console.log("Game controller connected")
    console.log("Total matches needed:", this.totalMatches)
  }

  disconnect() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
  }

  updateTimer() {
    const elapsed = Math.floor((Date.now() - this.startTime) / 1000)
    const minutes = Math.floor(elapsed / 60)
    const seconds = elapsed % 60
    this.timerTarget.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  selectOrigin(event) {
    const card = event.currentTarget
    const setId = card.dataset.setId

    // 既に完了した起点カードは選択不可
    if (this.selectedOriginCompleted.has(setId)) {
      this.showMessage("この起点カードは既に完了しています", "warning")
      return
    }

    // 現在の状態に関係なく起点カードは選択可能
    // 既に選択されている起点カードを解除
    this.originCardTargets.forEach(c => {
      c.classList.remove('ring-4', 'ring-accent', 'ring-offset-2')
    })

    // 新しい起点カードを選択
    card.classList.add('ring-4', 'ring-accent', 'ring-offset-2')
    this.selectedOriginId = setId
    this.gameState = "SELECT_RELATED"

    this.showMessage("起点カードを選択しました。関連語を選んでください！", "info")
  }

  selectRelated(event) {
    const card = event.currentTarget
    const setId = card.dataset.setId
    const relatedWord = card.dataset.word

    // 既に選択済みのカードは無視
    if (card.classList.contains('opacity-50')) {
      return
    }

    if (this.gameState === "SELECT_ORIGIN") {
      this.showMessage("まず起点カードを選択してください", "warning")
      return
    }

    if (!this.selectedOriginId) {
      this.showMessage("まず起点カードを選択してください", "warning")
      return
    }

    // 選択した関連語が現在の起点カードとマッチするかチェック
    if (setId === this.selectedOriginId) {
      // 正解の場合
      this.handleCorrectMatch(card, setId, relatedWord)
    } else {
      // 不正解の場合
      this.showMessage("選択したカードは、現在の起点カードとセットになっていません", "error")
    }
  }

  async handleCorrectMatch(cardElement, setId, relatedWord) {
    try {
      const response = await fetch(`/games/${this.questionId}/check_match`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          origin_set_id: setId,
          related_word: relatedWord
        })
      })

      const result = await response.json()

      if (result.correct) {
        // カードを無効化
        cardElement.classList.add('opacity-50', 'cursor-not-allowed')
        cardElement.classList.remove('hover:scale-105')
        cardElement.removeAttribute('data-action')
        
        this.correctMatches = result.total_matches
        this.correctClicks = result.correct_clicks
        this.totalClicks = result.total_clicks
        this.scoreTarget.textContent = this.correctMatches
        
        this.showMessage(`正解！ (正答率: ${result.current_accuracy}%)`, "success")

        // この起点カードの関連語が全て完了したかチェック
        await this.checkOriginCompletion(setId)

        // ゲーム完了チェック
        if (result.game_completed) {
          setTimeout(() => this.showCompletionModal(), 1000)
        }
      } else {
        this.totalClicks = result.total_clicks
        this.showMessage(`不正解... (正答率: ${result.current_accuracy}%)`, "error")
      }

    } catch (error) {
      console.error('Error checking match:', error)
      this.showMessage("エラーが発生しました", "error")
    }
  }

  async checkOriginCompletion(setId) {
    // 現在の起点カードに対応する関連語カードが全て選択済みかチェック
    const relatedCards = this.relatedCardTargets.filter(card => 
      card.dataset.setId === setId && !card.classList.contains('opacity-50')
    )

    if (relatedCards.length === 0) {
      // この起点カードは完了
      this.selectedOriginCompleted.add(setId)
      
      // 起点カードを完了状態にする
      const originCard = this.originCardTargets.find(card => card.dataset.setId === setId)
      if (originCard) {
        originCard.classList.remove('ring-4', 'ring-accent', 'ring-offset-2')
        originCard.classList.add('opacity-50', 'cursor-not-allowed')
        originCard.classList.remove('hover:scale-105')
        originCard.removeAttribute('data-action')
      }

      // 次の起点カードを選択する状態に戻る
      this.selectedOriginId = null
      this.gameState = "SELECT_ORIGIN"
      
      this.showMessage("この起点カードが完了しました！次の起点カードを選択してください", "success")
    }
  }

  showMessage(text, type) {
    this.messageTextTarget.textContent = text
    
    // アラートクラスをリセット
    this.messageTarget.className = "alert shadow-lg"
    
    // タイプに応じてクラス追加
    switch(type) {
      case "success":
        this.messageTarget.classList.add("alert-success")
        break
      case "error":
        this.messageTarget.classList.add("alert-error")
        break
      case "warning":
        this.messageTarget.classList.add("alert-warning")
        break
      default:
        this.messageTarget.classList.add("alert-info")
    }

    this.messageTarget.classList.remove("hidden")

    setTimeout(() => {
      this.messageTarget.classList.add("hidden")
    }, 3000) // メッセージ表示時間を少し長くする
  }

  showCompletionModal() {
    const elapsed = Math.floor((Date.now() - this.startTime) / 1000)
    const minutes = Math.floor(elapsed / 60)
    const seconds = elapsed % 60
    
    this.finalScoreTarget.textContent = this.correctMatches
    this.finalTimeTarget.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    
    this.completionModalTarget.classList.add("modal-open")
    
    // タイマー停止
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
  }

  giveUp() {
    if (confirm("本当にギブアップしますか？")) {
      window.location.href = `/games/${this.questionId}/result`
    }
  }
}