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
end
