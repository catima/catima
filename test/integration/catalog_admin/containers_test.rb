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
    find('div.translatedTextField input[data-locale=en]').base.send_keys("Container test page")
    click_on('Create page')

    visit('/one/en/container-test')
    within('h1') { assert(page.has_content?('Container test page')) }

    click_on('Edit this page')
    find("#add-field-dropdown").click
    click_on('Markdown')

    fill_in('Slug', :with => 'test-md')
    fill_in('Markdown', :with => '**Bold text**')
    click_on('Create container')
    assert(page.has_content?('The “test-md” container has been created.'))

    new_window = window_opened_by { click_on("View page") }
    within_window new_window do
      within('strong') { assert(page.has_content?('Bold text')) }
    end
  end

  test "creates a contact container" do
    log_in_as("one-admin@example.com", "password")
    visit('/one/en/one')

    click_on('Edit this page')
    find("#add-field-dropdown").click
    click_on('Contact')

    fill_in('Slug', :with => 'test-contact')
    fill_in('Receiving email', :with => 'test@email.ch')
    click_on('Create container')

    new_window = window_opened_by { click_on("View page") }
    within_window new_window do
      assert(page.has_css?('input#name'))
      assert(page.has_css?('input#email'))
      assert(page.has_css?('input#subject'))
      assert(page.has_css?('textarea#body'))
    end
  end

  test "creates a search container" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_pages/one/edit")

    find("#add-field-dropdown").click
    click_on("Search")

    fill_in("Slug", :with => "book-search")
    select("list", :from => "Style")
    select("book search", :from => "Saved search")
    click_on("Create container")

    new_window = window_opened_by { click_on("View page") }
    within_window new_window do
      assert(page.has_content?("Stephen"))
    end
  end

  test "edit a line container" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_pages/line_one/edit")
    find(".container-action-edit").click
    sleep(2)
    select("Age", :from => "Sort field")
    click_on("Save container")
    find(".container-action-edit").click
    assert(find('option[selected="selected"][value="128780868"]'))
  end
end
