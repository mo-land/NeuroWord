// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

// DOMContentLoadedとturbo:loadの両方に対応
function initializeTagify() {
  setTimeout(() => {
    const tagInput = document.querySelector('#tag-input')
    
    if (tagInput && typeof Tagify !== 'undefined') {
      // 既に初期化されている場合は削除（重複初期化を防ぐ）
      if (tagInput.tagify) {
        tagInput.tagify.destroy()
      }
      
      const tagify = new Tagify(tagInput, {
        dropdown: {
          maxItems: 20,
          enabled: 0,
          closeOnSelect: false
        }
      })
      
      // プレースホルダーと枠線の色を設定
      const style = document.createElement('style')
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
      
      // 参照を保存（次回の削除用）
      tagInput.tagify = tagify
      
      console.log('Tagify initialized successfully!') // デバッグ用
    } else {
      console.log('Tagify initialization failed:', {
        tagInput: !!tagInput,
        tagifyLoaded: typeof Tagify !== 'undefined'
      })
    }
  }, 100)
}

// 通常のページ読み込み
document.addEventListener('DOMContentLoaded', initializeTagify)

// Turbo Drive によるページ遷移
document.addEventListener('turbo:load', initializeTagify)

// フレーム更新時（Turbo Frame使用時）
document.addEventListener('turbo:frame-load', initializeTagify)

