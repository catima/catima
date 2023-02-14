require "test_helper"

class Admin::UsersTest < ActionDispatch::IntegrationTest
  test "create a system admin" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")
    click_on("New admin user")
    fill_in("Email", :with => "testing@example.com")
    check("System admin")

    assert_difference("User.where(:system_admin => true).count") do
      click_on("Send invitation")
    end
  end

  test "create a catalog admin" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")
    click_on("New admin user")
    fill_in("Email", :with => "testing@example.com")
    check("one")

    assert_difference("User.count") do
      click_on("Send invitation")
    end

    user = User.where(:email => "testing@example.com").first!
    refute(user.system_admin?)
    assert_equal([catalogs(:one)], user.admin_catalogs)
  end

  test "delete a user (soft delete)" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")

    assert_difference("User.count", -1) do
      first("a.user-action-delete").click
    end

    # Assert that the user is just soft deleted.
    assert_no_difference("User.with_deleted.count") do
      first("a.user-action-delete").click
    end
  end

  test "can't log-in as a deleted user" do
    log_in_as("one-user-deleted@example.com", "password")
    within("body>.container") do
      assert(page.has_content?(/Invalid Email or password./i))
    end
  end
end
