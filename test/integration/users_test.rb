require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  test "can't log-in as a deleted user" do
    log_in_as("one-user-deleted@example.com", "password")
    within("body>.container") do
      assert(page.has_content?(/Invalid Email or password./i))
    end
  end

  test "create a user with the same email as a deleted user" do
    visit("/en/register")
    fill_in("Email", :with => "one-user-deleted@example.com")
    fill_in("Password", :with => "password")
    fill_in("Password confirmation", :with => "password")

    assert_difference("User.count", 1) do
      click_on("Sign up")
    end
  end

  test "create a user with the same email as a not deleted user" do
    visit("/en/register")
    fill_in("Email", :with => "one-user@example.com")
    fill_in("Password", :with => "password")
    fill_in("Password confirmation", :with => "password")

    assert_no_difference("User.count") do
      click_on("Sign up")
    end
  end
end
