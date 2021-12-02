require "test_helper"

class CatalogAdmin::ApiTest < ActionDispatch::IntegrationTest
  test "view an API key" do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_api')

    assert(page.has_content?('key2'))
    assert(page.has_content?('thisisnotasecureapikey_two'))
  end

  test "create an API key" do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_api')

    find('i.fa-plus').click
    find('div#new-api-key-modal').fill_in("Label", :with => "API test key")

    assert_difference('APIKey.count', +1) do
      find('div#new-api-key-modal').click_on('Create')
    end

    assert(page.has_content?('API test key'))
  end

  test "delete an API key" do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_api')

    assert_difference('APIKey.count', -1) do
      find('a.delete-api-key').click
    end
  end
end
