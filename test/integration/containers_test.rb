require "test_helper"

class ContainersTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

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

  test "view timeline container" do
    timeline_page = pages(:timeline_one)
    visit("/one/en/#{timeline_page.to_param}")
    sleep(4)
    within first('.timeline__group__title') do
      assert(page.has_content?("No"))
      assert(page.has_content?("Very Young"))
      refute(page.has_content?("Very Old"))
    end

    within last('.timeline__group__title') do
      assert(page.has_content?("Yes"))
      assert(page.has_content?("Very Old"))
      refute(page.has_content?("Very Young"))
    end
  end
end
