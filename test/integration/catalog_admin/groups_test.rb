require "test_helper"

class CatalogAdmin::GroupsTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "create a group" do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_users')
    click_on('Create group')
    fill_in('Name', with: 'group-test-catalog-two')
    fill_in('Description', with: 'Description of test group for catalog two')

    assert_difference('Group.count', +1) do
      click_on('Create group')
    end

    group = Group.where(name: 'group-test-catalog-two').first!
    assert_equal(group.catalog.id, catalogs(:two).id)
    assert_equal(group.description, 'Description of test group for catalog two')
    assert_equal(group.owner, users(:two_admin))
  end

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

  test 'add users to group' do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_users')

    first("a.group-action-add").click
    assert(page.has_content?('group members'))
    click_on('Add users')

    fill_in('members_to_invite_', with: "Albert <einstein@example.com>\none@example.com")
    click_on('Add members')

    assert(page.has_content?('einstein@example.com'))
    assert_not(page.has_content?('Albert'))
    assert(page.has_content?('one@example.com'))

    albert = User.find_by(email: 'einstein@example.com')
    assert_not(albert.nil?)
    assert_equal(users(:two_admin), albert.invited_by)

    assert(albert.catalog_role_at_least?(catalogs(:two), 'member'))
  end

  test 'delete group' do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_users')

    click_on('Create group')
    fill_in('Name', with: 'group-for-catalog-two-to-be-deleted')

    assert_difference('Group.count', +1) do
      click_on('Create group')
    end

    assert_difference('Group.count', -1) do
      page.accept_alert(wait: 2) do
        find('#group-permissions-table tbody tr:nth-of-type(2) a[data-method="delete"]').click
      end
      sleep 2
    end
  end

  test 'cancel group editing' do
    log_in_as('two-admin@example.com', 'password')
    visit('/two/en/admin/_users')

    assert(page.has_content?('Group for catalog two'))
    first("a.group-action-edit").click
    fill_in('Name', with: 'Alternative name for group')
    click_on('Cancel')

    assert(page.has_content?('two Setup'))
    assert(page.has_content?('Group for catalog two'))
  end

  test 'deactivate group' do
    log_in_as('two-admin@example.com', 'password')
    visit('/en/_groups')

    assert(page.has_content?('Group for catalog two'))

    visit('/two/en/admin/_users')

    assert(page.has_content?('Group for catalog two'))
    first("a.group-action-edit").click

    uncheck("Active?")
    click_on('Update group')

    visit('/en/_groups')

    refute(page.has_content?('Group for catalog two'))
  end

  test 'join a public group' do
    log_in_as('two@example.com', 'password')
    visit('/en/_groups')

    refute(page.has_content?('Group for catalog one'))

    fill_in 'group-join-input', :with => 'one-11-44444444'
    click_on('Join the group')

    assert(page.has_content?('Group for catalog one'))
    assert(page.has_content?('You are now a member of the «Group for catalog one» group'))
  end
end
