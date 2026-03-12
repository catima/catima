require "test_helper"
require 'pry'

class CatalogAdmin::PagesTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "cannot create a page with existing item type slug" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_pages/new")

    fill_in("Slug", :with => "books")
    find('div.translatedTextField input[data-locale=en]').base.send_keys('Existing slug...')

    assert_no_difference("catalogs(:one).pages.count") do
      click_on("Create page")
    end

    assert(page.has_content?("already been taken by an item type"))
  end

end
