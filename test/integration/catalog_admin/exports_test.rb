require "test_helper"

class CatalogAdmin::ExportsTest < ActionDispatch::IntegrationTest
  test "create a catima export" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/_exports")

    first("button", :text => "New export (choose format)").click
    first("a", :text => "Catima").click

    assert(page.has_content?("New catima export"))

    assert_difference("Export.count", + 1) do
      uncheck("Add files")
      click_on("Create export")
    end

    assert(page.has_content?("two-admin@example.com"))
    assert(page.has_content?("processing"))
    assert(page.has_content?("valid"))
  end
end
