// app/javascript/controllers/card_set_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["originInput", "originCount", "relatedInput", "relatedCount", 
                   "relatedWordsContainer", "relatedWordGroup", "addButton", "submitButton"]

  connect() {
    this.updateAllCharCounts()
    this.updateAddButtonState()
  }

  updateCharCount(event) {
    const input = event.target
    const maxLength = parseInt(input.getAttribute('maxlength')) || 40
    const remaining = maxLength - input.value.length
    
    // より正確にカウンター要素を特定
    let countElement = null
    
    // 起点単語の場合
    if (input.hasAttribute('data-card-set-form-target') && input.getAttribute('data-card-set-form-target').includes('originInput')) {
      countElement = input.closest('.form-control').querySelector('[data-card-set-form-target="originCount"]')
    } 
    // 関連語の場合
    else {
      // 該当する入力フィールドの直後にあるカウンター要素を探す
      const inputGroup = input.closest('[data-card-set-form-target="relatedWordGroup"]')
      if (inputGroup) {
        const nextDiv = inputGroup.nextElementSibling
        if (nextDiv && nextDiv.classList.contains('text-xs')) {
          countElement = nextDiv.querySelector('[data-card-set-form-target="relatedCount"]')
        }
      }
    }
    
    if (countElement) {
      countElement.textContent = remaining
      
      // 文字数が少なくなったら警告色に
      if (remaining < 5) {
        countElement.classList.add('text-warning')
      } else {
        countElement.classList.remove('text-warning')
      }
    } else {
      console.log('カウンター要素が見つかりません:', input)
    }
    
    this.updateAddButtonState()
  }

  addRelatedWord() {
    const container = this.relatedWordsContainerTarget
    const currentGroups = this.relatedWordGroupTargets
    const index = currentGroups.length
    
    // 最大9個の関連語まで
    if (index >= 9) {
      alert('関連語は最大9個まで追加できます')
      return
    }

    const newGroup = document.createElement('div')
    newGroup.className = 'flex gap-2'
    newGroup.setAttribute('data-card-set-form-target', 'relatedWordGroup')
    
    newGroup.innerHTML = `
      <input type="text" 
             name="card_set[related_words][]" 
             class="input input-bordered flex-1"
             maxlength="40"
             placeholder="関連語 ${index + 1}"
             data-action="input->card-set-form#updateCharCount"
             data-card-set-form-target="relatedInput">
      
      <button type="button" 
              class="btn btn-outline btn-error btn-square"
              data-action="click->card-set-form#removeRelatedWord">
        <i class="fas fa-times"></i>
      </button>
    `
    
    // カウンター要素を追加
    const countDiv = document.createElement('div')
    countDiv.className = 'text-xs text-base-content/70 ml-1'
    countDiv.innerHTML = '残り<span data-card-set-form-target="relatedCount">40</span>文字'
    
    container.appendChild(newGroup)
    container.appendChild(countDiv)
    
    this.updateAddButtonState()
    
    // 新しく追加された入力フィールドにフォーカス
    const newInput = newGroup.querySelector('input')
    newInput.focus()
  }

  removeRelatedWord(event) {
    const wordGroup = event.target.closest('[data-card-set-form-target="relatedWordGroup"]')
    const countDiv = wordGroup.nextElementSibling
    
    // グループとカウンターの両方を削除
    if (countDiv && countDiv.classList.contains('text-xs')) {
      countDiv.remove()
    }
    wordGroup.remove()
    
    this.updateAddButtonState()
    this.renumberPlaceholders()
  }

  updateAllCharCounts() {
    // 起点単語のカウント更新
    if (this.hasOriginInputTarget) {
      const event = { target: this.originInputTarget }
      this.updateCharCount(event)
    }
    
    // 関連語のカウント更新
    this.relatedInputTargets.forEach(input => {
      const event = { target: input }
      this.updateCharCount(event)
    })
  }

  updateAddButtonState() {
    if (this.hasAddButtonTarget) {
      const currentGroups = this.relatedWordGroupTargets.length
      this.addButtonTarget.disabled = currentGroups >= 9
      
      if (currentGroups >= 9) {
        this.addButtonTarget.classList.add('btn-disabled')
      } else {
        this.addButtonTarget.classList.remove('btn-disabled')
      }
    }
  }

  renumberPlaceholders() {
    this.relatedInputTargets.forEach((input, index) => {
      input.placeholder = `関連語 ${index + 1}`
    })
  }
}