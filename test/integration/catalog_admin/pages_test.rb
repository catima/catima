require "test_helper"

class CatalogAdmin::PagesTest < ActionDispatch::IntegrationTest
  test "create a page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin")
    click_on("Setup")
    click_on("Pages")
    click_on("New page")

    fill_in("Slug", :with => "hello")
    fill_in("Title", :with => "Hello, World!")
    fill_in("Content", :with => "<p>Some HTML content</p>")

    assert_difference("catalogs(:one).pages.count") do
      click_on("Create page")
    end

    model = catalogs(:one).pages.where(:slug => "hello").first!
    assert_equal("en", model.locale)
    assert_equal(users(:one_admin), model.creator)
    assert_equal("Hello, World!", model.title)
    assert_equal("<p>Some HTML content</p>", model.content)

    visit("/one/en/hello")
    within("h1") { assert(page.has_content?("Hello, World!")) }
    assert(page.has_selector?("p", :text => "Some HTML content"))
  end

  test "create pages for two languages" do
    log_in_as("multilingual-admin@example.com", "password")
    visit("/multilingual/admin")
    click_on("Setup")
    click_on("Pages")
    click_on("New page")

    select("Français", :from => "Language")
    fill_in("Slug", :with => "hello")
    fill_in("Title", :with => "Bonjour")
    fill_in("Content", :with => "<p>French content</p>")
    click_on("Create and add another")

    select("English", :from => "Language")
    fill_in("Slug", :with => "hello")
    fill_in("Title", :with => "Hello")
    fill_in("Content", :with => "<p>English content</p>")
    click_on("Create page")

    visit("/multilingual/fr/hello")
    within("h1") { assert(page.has_content?("Bonjour")) }
    assert(page.has_selector?("p", :text => "French content"))

    visit("/multilingual/en/hello")
    within("h1") { assert(page.has_content?("Hello")) }
    assert(page.has_selector?("p", :text => "English content"))
  end

  test "edit a page" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin")
    click_on("Setup")
    click_on("Pages")
    first("a", :text => "Edit").click

    fill_in("Title", :with => "Changed by test")

    assert_no_difference("Page.count") do
      click_on("Update page")
    end

    model = pages(:one)
    assert_equal("Changed by test", model.title)
  end

  test "delete an item" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin")
    click_on("Setup")
    click_on("Pages")

    assert_difference("Page.count", -1) do
      first("a", :text => "Delete").click
    end
  end
end
