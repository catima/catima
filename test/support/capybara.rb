# Capybara + Selenium Chrome allow JS testing via headless webkit
require "capybara/rails"

Capybara.server_port = 3000

if ENV['DOCKER_RUNNING'].present?
  Capybara.javascript_driver = :remote_chrome
  Capybara.configure do |config|
    config.server = :puma, { Silent: true }
    config.server_host = "catima-app"
    config.server_port = 4000
  end
else
  Capybara.javascript_driver = :chrome
end

def driver_params
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('disable-infobars')
  options.add_argument('disable-gpu')
  options.add_argument('headless') unless ENV['HEADLESS'] == '0'
  options.add_argument('no-sandbox')
  options.add_argument('disable-dev-shm-usage')
  options.add_argument('unhandled-prompt-behavior=ignore')
  options.add_argument('disable-backgrounding-occluded-windows')
  options.web_socket_url = false
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

  setup do
    Capybara.use_default_driver
    Capybara.current_session.driver.browser.clear_cookies
  end

  def use_javascript_capybara_driver
    Capybara.current_driver = Capybara.javascript_driver
    browser = Capybara.current_session.driver.browser
    browser.manage.window.resize_to(1200, 800)
    Capybara.default_max_wait_time = 12
    browser.manage.delete_all_cookies
  end
end

# Monkey patch so that AR shares a single DB connection among all threads.
# This ensures data consistency between the test thread and poltergeist thread.
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
