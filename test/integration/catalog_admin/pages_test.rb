require "test_helper"

class CatalogAdmin::PagesTest < ActionDispatch::IntegrationTest
  test "create a page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Setup")
    click_on("Pages")
    click_on("New page")

    fill_in("Slug", :with => "hello")
    fill_in("Title", :with => '{"en": "Hello, World!"}')

    assert_difference("catalogs(:one).pages.count") do
      click_on("Create page")
    end

    model = catalogs(:one).pages.where(:slug => "hello").first!
    assert_equal(users(:one_admin), model.creator)
    assert_equal("Hello, World!", model.title)
    assert_equal('{"en":"Hello, World!"}', model.title_str)
    assert_equal("Hello, World!", model.title_json['en'])

    visit("/one/en/hello")
    within("h1") { assert(page.has_content?("Hello, World!")) }
  end

  test "create pages for two languages" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/en/admin")
    click_on("Setup")
    click_on("Pages")
    click_on("New page")

    fill_in("Slug", :with => "hello")
    fill_in("Title", :with => '{"fr": "Bonjour", "en": "Hello"}')
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
    first("a", :text => "Edit").click

    fill_in("Title", :with => '{"en": "Changed by test"}')

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
      first("a", :text => "Delete").click
    end
  end

  test "delete a page with menu item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Setup")
    click_on("Pages")

    while page.has_content?('Delete') do
      first('a', :text => 'Delete').click
    end

    click_on("New page")
    fill_in("Slug", :with => "hello")
    fill_in("Title", :with => '{"en": "Hello"}')
    click_on("Create page")

    click_on("Menu items")
    click_on('New menu item')
    fill_in('Slug', :with => 'hello-menu')
    fill_in('Title', :with => '{"en": "Hello menu"}')
    fill_in('Rank', :with => '10')
    select('Hello', :from => 'Page')
    click_on('Create menu item')

    visit('/one')
    within("div.navbar-collapse") { assert(page.has_content?("Hello menu")) }

    visit('/one/en/admin')
    click_on('Pages')
    assert_difference("Page.count", -1) do
      first("a", :text => "Delete").click
    end
  end
end
