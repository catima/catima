# Capybara + Selenium Chrome allow JS testing via headless webkit
require "capybara/rails"

Capybara.server = :puma, { Silent: true, Threads: "1:1" }

if ENV['DOCKER_RUNNING'].present?
  Capybara.javascript_driver = :remote_chrome
  Capybara.configure do |config|
    config.server_host = "catima-app"
    config.server_port = 4000
  end
else
  Capybara.javascript_driver = :chrome
  Capybara.server_port = 3000
end

def driver_params
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--window-size=1920,1200')
  options.add_argument('--disable-smooth-scrolling')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--no-first-run')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--headless=new') unless ENV['HEADLESS'] == '0'
  { options: options }
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    **driver_params
  )
end

Capybara.register_driver :remote_chrome do |app|
  Capybara::Selenium::Driver.new(
    app,
    url: "http://catima-selenium:4444/wd/hub",
    browser: :remote,
    **driver_params
  )
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  self.use_transactional_tests = true

  setup do
    Capybara.use_default_driver
    Capybara.reset_sessions!
  end

  def use_javascript_capybara_driver
    Capybara.current_driver = Capybara.javascript_driver
    browser = Capybara.current_session.driver.browser
    browser.manage.window.resize_to(1200, 800)
    Capybara.default_max_wait_time = 12
    browser.manage.delete_all_cookies
  end
end
