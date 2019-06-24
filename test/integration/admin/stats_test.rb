require "test_helper"

class Admin::StatsTest < ActionDispatch::IntegrationTest
  test "show catalog stats to system admin and back to dashboard" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")

    within('.catalogs') do
      click_on("Stats")
    end

    assert(page.has_content?("Stats | catalogs"))
    assert(page.has_content?("Pageview, all"))
    assert(page.has_content?("Pageview, admin"))
    assert(page.has_content?("Pageview, front"))

    click_on("Catima admin dashboard")

    within('.catalogs') do
      assert(page.has_content?("Stats"))
    end
  end

  test "redirected to dashboard if stats scope parameter is wrong" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin/stats?scope=hello")

    assert(page.has_content?("Scope not available"))
  end

  test "hide catalog stats link to catalog admins" do
    log_in_as("one-admin@example.com", "password")
    visit("/admin")

    within('.catalogs') do
      refute(page.has_content?("Stats"))
    end
  end

  test "raise auth error if user is not a system admin" do
    log_in_as("one-admin@example.com", "password")

    assert_raises(Pundit::NotAuthorizedError) do
      visit("/admin/stats?scope=catalogs")
    end
  end
end
