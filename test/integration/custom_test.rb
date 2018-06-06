require "test_helper"

class CustomTest < ActionDispatch::IntegrationTest
  test "view a custom page by slug" do
    with_customized_file("test/custom/views/custom/my-test-page.html.erb",
                         "catalogs/one/views/custom/my-test-page.html.erb") do
      visit("/one/en/my-test-page")
    end
    assert(page.has_content?("This is a custom page"))
    assert(page.has_content?("Stephen King"))
    assert(page.has_content?("Very Old"))
  end

  # unless ENV['TRAVIS']
  test "custom catalog controller is invoked correctly for catalog with a dash in slug" do
    visit("/custom-with-dash/en")
    assert(page.has_content?(/one/i))
  end

  test "custom items controller is invoked instead of default controller" do
    visit('/custom-with-dash/en/authors')
    assert(page.has_content?("Stephen King"))
    assert(page.has_content?("Very Old"))
  end

  test "custom search controller is invoked instead of default controller" do
    visit('/custom-with-dash/en/search')
    assert(page.has_content?("Stephen King"))
    assert(page.has_content?("Very Old"))
  end
  # end

  test "creating new catalog does not break routes with customizable controllers" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")
    click_on("New catalog")
    fill_in("Name", :with => "Customizable controllers test catalog")
    fill_in("Slug", :with => "custom-test-catalog")
    select("English", :from => "Primary language")

    assert_difference("Catalog.count") do
      click_on("Create catalog")
    end

    visit('/custom-test-catalog/en')
    assert(page.has_content?("Customizable controllers test catalog"))
  end
end
