require "test_helper"

class CatalogAdmin::CatalogsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "set catalog visibility" do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_settings')

    catalog = Catalog.find_by(slug: 'two')
    assert(catalog.visible?)
    assert_not(catalog.restricted?)
    assert_equal(find('#catalog_access').value, '1')

    select('Open to members', from: 'catalog_access')
    click_on('Save')
    sleep 2

    catalog = Catalog.find_by(slug: 'two')
    assert(catalog.visible?)
    assert(catalog.restricted?)

    visit('/two/en/admin/_settings')
    assert_equal(find('#catalog_access').value, '2')

    select('Open to catalog staff', from: 'catalog_access')
    click_on('Save')
    sleep 2

    catalog = Catalog.find_by(slug: 'two')
    assert_not(catalog.visible?)
  end
end
