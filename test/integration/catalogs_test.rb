require "test_helper"

class CatalogsTest < ActionDispatch::IntegrationTest
  test "redirects to catalog default language for guest" do
    visit("/multilingual")
    assert_equal("/multilingual/fr", current_path)
  end

  test "redirects to preferred language" do
    log_in_as("de@example.com", "password")
    visit("/multilingual")
    assert_equal("/multilingual/de", current_path)
  end

  test "remembers and redirects to last visited language" do
    log_in_as("de@example.com", "password")
    visit("/multilingual/it")
    visit("/multilingual")
    assert_equal("/multilingual/it", current_path)
  end

  test "renders correctly without custom style" do
    visit("/one")
    assert(page.has_content?(/one/i))
  end

  test "renders correctly with custom style" do
    visit("/two")
    assert(page.has_content?(/two/i))
  end
end
