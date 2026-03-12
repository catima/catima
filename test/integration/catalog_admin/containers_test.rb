require "test_helper"

class CatalogAdmin::ContainersTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "cannot create two itemlist containers in the same page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_pages/one-fdesc/edit")

    find("#add-field-dropdown").click
    click_on("ItemList")

    click_on("Create container")

    assert(page.has_content?('Multiple "ItemList" containers in the same page is not allowed'))
  end
end
