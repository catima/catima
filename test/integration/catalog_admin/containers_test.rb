require "test_helper"

class CatalogAdmin::ContainersTest < ActionDispatch::IntegrationTest
  test "create a container" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/admin")
    click_on("Setup")
    click_on('Pages')
    click_on('New page')

    fill_in('Slug', :with => 'container-test')
    fill_in('Title', :with => 'Container test page')
    click_on('Create page')

    visit('/one/en/container-test')
    within('h1') { assert(page.has_content?('Container test page')) }

    click_on('Edit this page')
    click_on('Markdown container')

    fill_in('Slug', :with => 'test-md')
    fill_in('Markdown', :with => '**Bold text**')
    click_on('Create container')
    assert(page.has_content?('The “test-md” container has been created.'))

    click_on('View page')
    within('strong') { assert(page.has_content?('Bold text')) }

    click_on('Edit this page')
    click_on('HTML container')
    fill_in('Slug', :with => 'test-html')
    fill_in('Html', :with => 'HTML container text content')
    click_on('Create container')

    click_on('View page')
    assert(page.has_content?('HTML container text content'))
  end
end
