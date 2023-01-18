require "test_helper"

class Admin::DashboardTest < ActionDispatch::IntegrationTest
  test "admin dashboard for sys admin is complete" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")
    assert(page.has_content?("Global settings"))
    assert(page.has_content?("Catalogs"))
    assert(page.has_content?("New admin user"))
    assert(page.has_content?("Custom templates"))
  end

  test "admin dashboard for catalog admin shows catalogs" do
    log_in_as("one-admin@example.com", "password")
    visit("/admin")
    assert_not(page.has_content?("Global settings"))
    assert(page.has_content?("Catalogs"))
    assert_not(page.has_content?("New admin user"))
    assert_not(page.has_content?("Custom templates"))
  end

  test "admin dashboard shows users" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")

    within("body>.container") do
      assert(page.has_content?("system-admin@example.com"))
      assert(page.has_content?("one@example.com"))
      refute(page.has_content?("one-user-deleted@example.com"))
    end
  end
end
