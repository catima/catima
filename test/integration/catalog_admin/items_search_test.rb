require "test_helper"

class CatalogAdmin::ItemsSearchTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "displays the items the admin is searching for" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin/authors")
    fill_in("q", :with => "Steve")
    click_on('Search')

    assert(page.has_content?('Stephen King'))
  end

  test "displays the items the admin is searching for in the right order" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin/authors")
    fill_in("q", :with => "old")
    click_on("Search")

    assert(page.has_content?("Very Old"))
    assert(page.has_content?("Very Young"))

    assert_equal(find(:xpath, "//table/tbody/tr[1]/td[1]").text, "Very Old")
    assert_equal(find(:xpath, "//table/tbody/tr[2]/td[1]").text, "Very Young")
  end
end
