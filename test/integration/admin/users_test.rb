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

  test "delete a user" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")

    assert_difference("User.count", -1) do
      first("a.user-action-delete").click
    end
  end
end
