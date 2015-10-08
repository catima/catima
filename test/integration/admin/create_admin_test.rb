require "test_helper"

class Admin::CreateAdminTest < ActionDispatch::IntegrationTest
  test "system admin can login and create another system admin" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin/users/new")
    fill_in("Email", :with => "testing@example.com")
    check("System admin")

    assert_difference("User.where(:system_admin => true).count") do
      click_on("Send invitation")
    end
  end
end
