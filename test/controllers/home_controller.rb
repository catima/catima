require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "robots.txt should include and exclude specific paths" do
    get robots_url
    assert_response :success
    assert_includes @response.content_type, "text/plain"
    assert_includes @response.body, "/search/"
    assert_includes @response.body, "/two/"
    assert_not_includes @response.body, "/one/"
  end
end
