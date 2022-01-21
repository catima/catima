require "test_helper"

class CatalogAdmin::ItemsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  include ItemReferenceHelper

  test "view suggestion on item page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Data")
    click_on("Authors")
    first("a.item-action-edit").click
    assert_not(page.has_content?(/existing_suggestion/i))
  end
end
