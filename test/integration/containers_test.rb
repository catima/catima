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
    within all('.timeline__group').first do
      assert(has_content?("No"))
      assert(has_content?("Very Young"))
    end

    within all('.timeline__group').last do
      assert(has_content?("Yes"))
      assert(has_content?("Very Old"))
      refute(has_content?("Stephen King"))
    end
  end
end
