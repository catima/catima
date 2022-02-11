require "test_helper"
require 'pry'

class CatalogAdmin::PagesTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "create a page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Setup")
    click_on("Pages")
    click_on("New page")

    fill_in("Slug", :with => "hello")
    find('div.translatedTextField input[data-locale=en]').base.send_keys('Hello, World...')

    assert_difference("catalogs(:one).pages.count") do
      click_on("Create page")
    end

    model = catalogs(:one).pages.where(:slug => "hello").first!
    assert_equal(users(:one_admin), model.creator)
    assert_equal("Hello, World...", model.title)
    assert_equal('{"en":"Hello, World..."}', model.title_str)
    assert_equal("Hello, World...", model.title_json['en'])

    visit("/one/en/hello")
    within("h1") { assert(page.has_content?("Hello, World...")) }
  end

  test "create pages for two languages" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/en/admin")
    click_on("Setup")
    click_on("Pages")
    click_on("New page")

    fill_in("Slug", :with => "hello")
    find('div.translatedTextField input[data-locale=en]').base.send_keys('Hello')
    find('div.translatedTextField input[data-locale=fr]').base.send_keys('Bonjour')
    click_on("Create page")

    visit("/multilingual/fr/hello")
    within("h1") { assert(page.has_content?("Bonjour")) }

    visit("/multilingual/en/hello")
    within("h1") { assert(page.has_content?("Hello")) }
  end

  test "edit a page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Setup")
    click_on("Pages")
    all("a.page-action-edit").last.click

    find('div.translatedTextField input[data-locale=en]').base.send_keys([:backspace] * 22, 'Changed by test')

    assert_no_difference("Page.count") do
      click_on("Update page")
    end

    model = pages(:one)
    assert_equal("Changed by test", model.title)
  end

  test "delete a page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Setup")
    click_on("Pages")
    assert_difference("Page.count", -1) do
      page.accept_alert(:wait => 2) do
        first("a.page-action-delete").click
      end
      sleep 2 # Wait for page count to be correct
    end
  end

  test "delete a page with menu item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Setup")
    click_on("Pages")

    while page.has_content?('Delete') do
      page.accept_alert(:wait => 2) do
        first("a", :text => "Delete").click
      end
    end

    click_on("New page")
    fill_in("Slug", :with => "hello")
    find('div.translatedTextField input[data-locale=en]').base.send_keys('Hello')
    click_on("Create page")

    click_on("Menu items")
    click_on('New menu item')
    fill_in('Slug', :with => 'hello-menu')
    first('div.translatedTextField input[data-locale=en]').base.send_keys('Hello menu')

    fill_in('Rank', :with => '10')
    select('Hello', :from => 'Page')
    click_on('Create menu item')

    visit('/one')
    within("div.navbar-collapse") { assert(page.has_content?("Hello menu")) }

    visit('/one/en/admin')
    click_on('Pages')

    assert_difference("Page.count", -1) do
      page.accept_alert(:wait => 2) do
        first("a.page-action-delete").click
      end
      sleep 2
    end
  end
end
