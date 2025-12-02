Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('no-sandbox')
  options.add_argument('headless')
  options.add_argument('disable-gpu')
  options.add_argument('window-size=1680,1050')
  Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV['SELENIUM_DRIVER_URL'], capabilities: options)
end

Capybara.register_driver :selenium_chrome_headless do |app|
  # CI環境ではwebdriversを無効化（Selenium Managerを使用）
  if ENV['CI']
    Selenium::WebDriver::Service.driver_path = '/usr/bin/chromedriver' if File.exist?('/usr/bin/chromedriver')
  end

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-software-rasterizer')
  options.add_argument('--disable-extensions')
  options.add_argument('--window-size=1680,1050')
  # メモリ関連の安定化オプション
  options.add_argument('--disable-features=VizDisplayCompositor')
  options.add_argument('--disable-background-timer-throttling')
  options.add_argument('--disable-renderer-backgrounding')
  options.add_argument('--disable-backgrounding-occluded-windows')

  # CI環境ではシステムのChromeを使用
  if ENV['CI']
    options.binary = '/usr/bin/google-chrome'
  end

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# JavaScriptが必要なテスト用のドライバーを設定
if ENV['SELENIUM_DRIVER_URL'].present?
  Capybara.javascript_driver = :remote_chrome
else
  Capybara.javascript_driver = :selenium_chrome_headless
end
