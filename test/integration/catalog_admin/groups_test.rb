require "test_helper"

class CatalogAdmin::GroupsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "change group role" do
    visit('/en/login')
    fill_in('Email', with: 'two-admin@example.com')
    fill_in('Password', with: 'password')
    click_on('Log in')

    visit('/two/en/admin/_users')

    catalog = catalogs(:two)
    user = users(:two_user)
    assert_equal('member', user.catalog_role(catalog))

    page.execute_script('document.querySelector("label.lbl-user").click()')
    sleep 2 # Wait for Ajax request to complete

    # Reload the page
    visit('/two/en/admin/_users')
    assert_equal(true, page.execute_script('return document.querySelector("[name=role][value=user]").checked'))
    assert_equal(false, page.execute_script('return document.querySelector("[name=role][value=member]").checked'))

    page.execute_script('document.querySelector("label.lbl-editor").click()')
    sleep 2
    visit('/two/en/admin/_users')
    assert_equal(false, page.execute_script('return document.querySelector("[name=role][value=user]").checked'))
    assert_equal(false, page.execute_script('return document.querySelector("[name=role][value=member]").checked'))
    assert_equal(true, page.execute_script('return document.querySelector("[name=role][value=editor]").checked'))

    page.execute_script('document.querySelector("label.lbl-super-editor").click()')
    sleep 2
    visit('/two/en/admin/_users')
    assert_equal(false, page.execute_script('return document.querySelector("[name=role][value=user]").checked'))
    assert_equal(false, page.execute_script('return document.querySelector("[name=role][value=member]").checked'))
    assert_equal(false, page.execute_script('return document.querySelector("[name=role][value=editor]").checked'))
    assert_equal(true, page.execute_script('return document.querySelector("[name=role][value=super-editor]").checked'))
  end
end
