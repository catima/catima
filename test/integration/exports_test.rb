require "test_helper"

class ExportsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "create an export" do
    log_in_as("system-admin@example.com", "password")
    visit("one/en/admin/_exports")
    click_on("New export (choose format)")
    click_on("Catima")

    assert_difference("Export.count", 1) do
      click_on("Create export")
    end
  end

  test "deleted user still displayed on export page" do
    log_in_as("system-admin@example.com", "password")
    visit("one/en/admin/_exports")
    assert(page.has_content?(users(:one_user_deleted).email))
  end
end
