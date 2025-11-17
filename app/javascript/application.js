// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// Tagifyインスタンスをグローバルに保持
let tagifyInstance = null

// DOMContentLoadedとturbo:loadの両方に対応
function initializeTagify() {
  const tagInput = document.querySelector('#tag-input')

  if (tagInput && typeof Tagify !== 'undefined') {
    // 既存のインスタンスを完全にクリーンアップ
    if (tagifyInstance) {
      tagifyInstance.destroy()
      tagifyInstance = null
    }

    // data-tagify-initialized属性で二重初期化をチェック
    if (tagInput.hasAttribute('data-tagify-initialized')) {
      return
    }

    tagifyInstance = new Tagify(tagInput, {
      dropdown: {
        maxItems: 20,
        enabled: 0,
        closeOnSelect: false
      }
    })

    // 初期化済みマーク
    tagInput.setAttribute('data-tagify-initialized', 'true')

    // スタイルは一度だけ追加
    if (!document.getElementById('tagify-custom-style')) {
      const style = document.createElement('style')
      style.id = 'tagify-custom-style'
      style.textContent = `
        .tagify__input::before {
          color: rgba(120, 49, 5, 0.4) !important;
        }
        .tagify {
          border-color: rgba(120, 49, 5, 0.4) !important;
          border-width: 1px !important;
        }
        .tagify:focus-within {
          border-color: rgba(120, 49, 5, 0.4) !important;
          box-shadow: 0 0 0 2px rgba(120, 49, 5, 0.2) !important;
        }
        .tagify .tagify__tag {
          border-color: rgba(120, 49, 5, 0.4) !important;
          border-width: 1px !important;
        }
      `
      document.head.appendChild(style)
    }
  }
}

// ページ離脱時にクリーンアップ
function cleanupTagify() {
  const tagInput = document.querySelector('#tag-input')
  if (tagInput) {
    tagInput.removeAttribute('data-tagify-initialized')
  }
  if (tagifyInstance) {
    tagifyInstance.destroy()
    tagifyInstance = null
  }
}

// 通常のページ読み込み
document.addEventListener('DOMContentLoaded', initializeTagify)

// Turbo Drive によるページ遷移（戻る/進むボタンにも対応）
document.addEventListener('turbo:load', initializeTagify)

// ページ離脱前にクリーンアップ
document.addEventListener('turbo:before-render', cleanupTagify)

// フレーム更新時（Turbo Frame使用時）
document.addEventListener('turbo:frame-load', initializeTagify)

