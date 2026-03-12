require "test_helper"

class SearchesTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }
  test "redirected to login with unauthenticated user" do
    visit("/one/en")
    fill_in("q", :with => "steve")
    click_on("Search")
    click_on("Save search")
    assert(page.has_content?("Log in"))
  end

  test "list empty searches for authenticated user" do
    log_in_as("one-reviewer@example.com", "password")
    visit("/en/searches")
    assert(page.has_content?("You don't have searches yet!"))
  end

  test "list searches for unauthenticated user" do
    visit("/en/searches")
    assert(page.has_content?("Log in"))
  end
end
