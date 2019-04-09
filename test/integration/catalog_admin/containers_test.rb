require "test_helper"

class CatalogAdmin::ContainersTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "create a container" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Setup")
    click_on('Pages')
    click_on('New page')

    fill_in('Slug', :with => 'container-test')
    fill_in('Title', :with => '{"en": "Container test page"}')
    click_on('Create page')

    visit('/one/en/container-test')
    within('h1') { assert(page.has_content?('Container test page')) }

    click_on('Edit this page')
    click_on('Markdown')

    fill_in('Slug', :with => 'test-md')
    fill_in('Markdown', :with => '**Bold text**')
    click_on('Create container')
    assert(page.has_content?('The “test-md” container has been created.'))

    click_on('View page')
    within('strong') { assert(page.has_content?('Bold text')) }

    click_on('Edit this page')
    click_on('HTML')
    fill_in('Slug', :with => 'test-html')
    fill_in('Html', :with => 'HTML container text content')
    click_on('Create container')

    click_on('View page')
    assert(page.has_content?('HTML container text content'))
  end

  test "creates a contact container" do
    log_in_as("one-admin@example.com", "password")
    visit('/one/en/one')

    click_on('Edit this page')
    click_on('Contact')

    fill_in('Slug', :with => 'test-contact')
    fill_in('Receiving email', :with => 'test@email.ch')
    click_on('Create container')

    click_on('View page')
    assert(page.has_css?('input#name'))
    assert(page.has_css?('input#email'))
    assert(page.has_css?('input#subject'))
    assert(page.has_css?('textarea#body'))
  end

  test "creates a search container" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_pages/one/edit")

    find("#add-field-dropdown").click
    click_on("Search")

    fill_in("Slug", :with => "book-search")
    fill_in("Description", :with => "You will find my saved search here!")
    select("list", :from => "Display type")
    select("book search", :from => "Saved search")
    click_on("Create container")

    new_window = window_opened_by { click_on("View page") }
    within_window new_window do
      assert(page.has_content?("You will find my saved search here!"))
    end
  end
end
