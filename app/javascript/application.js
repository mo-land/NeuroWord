// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

import * as echarts from 'echarts';
window.echarts = echarts;

// ローディングアニメーション
document.addEventListener('turbo:load', function () {
  const spinner = document.getElementById("loading");
  if (spinner) {
    spinner.classList.add("loaded");
  }
});

// 初回読み込み時
document.addEventListener('DOMContentLoaded', function () {
  const spinner = document.getElementById("loading");
  if (spinner) {
    spinner.classList.add("loaded");
  }
});

// Tagifyインスタンスをグローバルに保持
let tagifyInstance = null

// DOMContentLoadedとturbo:loadの両方に対応
function initializeTagify() {
  const tagInput = document.querySelector('#tag-input')
  
  // 要素チェック
  if (!tagInput || typeof Tagify === 'undefined') {
    return
  }
  
  // 二重初期化防止
  if (tagInput.classList.contains('tagify')) {
    return
  }
  
  // ここでデータ取得
  const existing_tags = JSON.parse(tagInput.dataset.existingTags)

  tagifyInstance = new Tagify(tagInput, {
    whitelist: existing_tags,
    maxTags: 10,
    dropdown: {
      maxItems: 20,
      classname: 'tags-look',
      enabled: 0,
      closeOnSelect: false
    }
  })

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

// ページ離脱時にクリーンアップ
function cleanupTagify() {
  if (tagifyInstance) {
    // JSON値をカンマ区切りに戻す
    const tags = tagifyInstance.value
    tagifyInstance.destroy()
    tagifyInstance = null
    
    const tagInput = document.querySelector('#tag-input')
     if (tagInput) {
      // .tagifyクラスが残っている場合は削除
      tagInput.classList.remove('tagify')
      
      // 値をカンマ区切りに戻す
      if (tags && tags.length > 0) {
        tagInput.value = tags.map(tag => tag.value).join(',')
      }
    }
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

// Service Worker登録
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/service-worker').catch((error) => {
      console.error('Service Worker registration failed:', error);
    });
  });
}
