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

  test "custom catalog controller is invoked correctly for catalog with a dash in slug" do
    visit("/custom-with-dash/en")
    assert(page.has_content?(/Welcome to custom catalog with dashes/i))
  end

  test "custom items controller is invoked instead of default controller" do
    visit('/custom-with-dash/en/authors')
    assert(page.has_content?("Stephen King"))
    assert(page.has_content?("Very Old"))
  end

  test "custom search controller is invoked instead of default controller" do
    visit('/custom-with-dash/en/search')
    refute(page.has_content?("Stephen King"))
    refute(page.has_content?("Very Old"))
  end

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

  test "allows custom view template" do
    config = Configuration.first!
    config.update!(:root_mode => "custom")

    with_customized_file(
      "test/custom/root.html.erb",
      "catalogs/root.html.erb") do
      visit("/")
      assert(page.has_content?(/this has been customized/i))
    end
  end

  test "allows override of fields.json per catalog" do
    catalog = catalogs(:one)
    with_customized_file("test/custom/config/fields.json",
                         "catalogs/one/config/fields.json") do
      config = JsonConfig.for_catalog(catalog).load("fields.json")
      expected_config = {
        "DateTime" => {
          "display_components" => ["Foo"],
          "editor_components" => []
        }
      }
      assert_equal(expected_config, config)
    end
  end
end
