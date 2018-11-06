require "test_helper"

class ContainersTest < ActionDispatch::IntegrationTest
  test "sends a contact request" do
    visit("/one/en/one")

    fill_in("Name", :with => "fake name")
    fill_in("Email", :with => "fake@email.ch")
    fill_in("Subject", :with => "subject")
    fill_in("Body", :with => "body")
    click_on("Send message")

    assert(page.has_content?("Message sent"))
  end

  test "has the required attribute for required fields" do
    visit("/one/en/one")

    assert(true, find_field('email')[:required])
    assert(true, find_field('body')[:required])
  end
end
