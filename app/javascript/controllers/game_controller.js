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

    // 常にAPIリクエストを送る（起点カード選択として）
    this.handleOriginClick(setId, card)
  }

  selectRelated(event) {
    const card = event.currentTarget
    const setId = card.dataset.setId
    const relatedWord = card.dataset.word

    // 常にAPIリクエストを送る（関連語カード選択として）
    this.handleRelatedClick(setId, relatedWord, card)
  }

  async handleOriginClick(setId, cardElement) {
    try {
      const response = await fetch(`/games/${this.questionId}/check_match`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          click_type: 'origin',
          origin_set_id: setId,
          related_word: null,
          current_state: this.gameState,
          selected_origin_id: this.selectedOriginId,
          is_completed: this.selectedOriginCompleted.has(setId)
        })
      })

      const record = await response.json()

      // クリック数を更新
      this.totalClicks = record.total_clicks
      this.correctClicks = record.correct_clicks

      if (record.valid_action) {
        // 有効なアクション（起点カード選択成功）
        
        // 既に選択されている起点カードを解除
        this.originCardTargets.forEach(c => {
          c.classList.remove('ring-4', 'ring-accent', 'ring-offset-2')
        })

        // 新しい起点カードを選択
        cardElement.classList.add('ring-4', 'ring-accent', 'ring-offset-2')
        this.selectedOriginId = setId
        this.gameState = "SELECT_RELATED"

        this.showMessage(record.message || "起点カードを選択しました。関連語を選んでください！", "info")
      } else {
        // 無効なアクション
        this.showMessage(record.message || "この起点カードは選択できません", "warning")
      }

    } catch (error) {
      console.error('Error handling origin click:', error)
      this.showMessage("エラーが発生しました", "error")
    }
  }

  async handleRelatedClick(setId, relatedWord, cardElement) {
    try {
      const response = await fetch(`/games/${this.questionId}/check_match`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          click_type: 'related',
          origin_set_id: this.selectedOriginId,
          related_word: relatedWord,
          clicked_set_id: setId,
          current_state: this.gameState,
          is_already_selected: cardElement.classList.contains('opacity-50')
        })
      })

      const record = await response.json()

      // クリック数を更新
      this.totalClicks = record.total_clicks
      this.correctClicks = record.correct_clicks

      if (record.correct && record.valid_action) {
        // 正解且つ有効なアクション
        cardElement.classList.add('opacity-50', 'cursor-not-allowed')
        cardElement.classList.remove('hover:scale-105')
        cardElement.removeAttribute('data-action')
        
        this.correctMatches = record.total_matches
        this.scoreTarget.textContent = this.correctMatches
        
        this.showMessage(`正解！ (正答率: ${record.current_accuracy}%)`, "success")

        // この起点カードの関連語が全て完了したかチェック
        await this.checkOriginCompletion(this.selectedOriginId)

        // ゲーム完了チェック
        if (record.game_completed) {
          setTimeout(() => this.showCompletionModal(), 1000)
        }
      } else {
        // 不正解または無効なアクション
        this.showMessage(record.message || `不正解... (正答率: ${record.current_accuracy}%)`, "error")
      }

    } catch (error) {
      console.error('Error handling related click:', error)
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
    }, 3000)
  }

  async showCompletionModal() {
    // タイマー停止
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }

    // ゲーム記録を保存
    try {
      await fetch(`/game_records`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          id: this.questionId,
          give_up: false
        })
      })
    } catch (error) {
      console.error('Error saving game record:', error)
    }

    const elapsed = Math.floor((Date.now() - this.startTime) / 1000)
    const minutes = Math.floor(elapsed / 60)
    const seconds = elapsed % 60
    
    this.finalScoreTarget.textContent = this.correctMatches
    this.finalTimeTarget.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    
    this.completionModalTarget.classList.add("modal-open")
  }

  async giveUp() {
    if (confirm("本当にギブアップしますか？")) {
      // タイマー停止
      if (this.timerInterval) {
        clearInterval(this.timerInterval)
      }

      // ゲーム記録を保存してから結果画面へ
      try {
        await fetch(`/game_records`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
          },
          body: JSON.stringify({
            id: this.questionId,
            give_up: true
          })
        })
        
        // 保存後に結果画面へリダイレクト
        window.location.href = `/game_records/${this.questionId}`
      } catch (error) {
        console.error('Error saving game record:', error)
        // エラーが発生してもリダイレクトする
        window.location.href = `/game_records/${this.questionId}?give_up=true`
      }
    }
  }
}