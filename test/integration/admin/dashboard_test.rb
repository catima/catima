require "test_helper"

class Admin::DashboardTest < ActionDispatch::IntegrationTest
  test "admin dashboard for sys admin is complete" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")
    assert(page.has_content?("Global settings"))
    assert(page.has_content?("Catalogs"))
    assert(page.has_content?("Users"))
    assert(page.has_content?("Custom templates"))
  end

  test "admin dashboard for catalog admin shows catalogs" do
    log_in_as("one-admin@example.com", "password")
    visit("/admin")
    assert_not(page.has_content?("Global settings"))
    assert(page.has_content?("Catalogs"))
    assert_not(page.has_content?("Users"))
    assert_not(page.has_content?("Custom templates"))
  end
end