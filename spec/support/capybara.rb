Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('no-sandbox')
  options.add_argument('headless')
  options.add_argument('disable-gpu')
  options.add_argument('window-size=1680,1050')
  Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV['SELENIUM_DRIVER_URL'], capabilities: options)
end

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-software-rasterizer')
  options.add_argument('--disable-extensions')
  options.add_argument('--window-size=1680,1050')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# JavaScriptが必要なテスト用のドライバーを設定
if ENV['SELENIUM_DRIVER_URL'].present?
  Capybara.javascript_driver = :remote_chrome
else
  Capybara.javascript_driver = :selenium_chrome_headless
end
