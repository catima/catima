require "test_helper"

class CatalogAdmin::ExportsTest < ActionDispatch::IntegrationTest
  test "create a catima export" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/_exports")

    assert_difference("Export.count", + 1) do
      first("button", :text => "New export (choose format)").click
      first("a", :text => "Catima").click
    end

    assert(page.has_content?("two-admin@example.com"))
    assert(page.has_content?("processing"))
    assert(page.has_content?("valid"))
  end
end
