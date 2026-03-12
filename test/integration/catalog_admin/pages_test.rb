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

  test "create pages for two languages" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/en/admin/_pages/new")

    fill_in("Slug", :with => "hello")
    find('div.translatedTextField input[data-locale=en]').base.send_keys('Hello')
    find('div.translatedTextField input[data-locale=fr]').base.send_keys('Bonjour')
    click_on("Create page")

    visit("/multilingual/fr/hello")
    within("h1") { assert(page.has_content?("Bonjour")) }

    visit("/multilingual/en/hello")
    within("h1") { assert(page.has_content?("Hello")) }
  end
end
