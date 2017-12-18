require "test_helper"

class CatalogAdmin::UsersTest < ActionDispatch::IntegrationTest
  test "create an editor" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_users")
    click_on("New user")
    fill_in("Email", :with => "testing@example.com")
    choose("Editor")
    select("Italiano", :from => "Preferred language")

    assert_difference("User.count") do
      click_on("Send invitation")
    end

    user = User.where(:email => "testing@example.com").first!
    assert_equal([catalogs(:one).id], user.editor_catalog_ids)
    assert_equal("it", user.primary_language)
  end

  test "edit a user" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/_users")
    first("a", :text => "Edit").click
    click_on("Update user")
    assert(page.has_content?("has been saved"))
  end
end
