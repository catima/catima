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

  test "check catalog visibility as guest" do
    visit("/not-visible")
    assert_equal("/", current_path)
    assert(page.has_content?(/is not accessible/i))
  end

  test "redirects if catalog is data_only" do
    log_in_as("data-only@example.com", "password")
    visit("/data-only")
    assert_equal("/", current_path)
    assert(page.has_content?(/is not accessible \(data only\)/i))
  end

  test "check catalog visibility as user" do
    log_in_as("one@example.com", "password")
    visit("/not-visible")
    assert_equal("/", current_path)
    assert(page.has_content?(/is not accessible/i))
  end

  test "check catalog visibility as member" do
    log_in_as("one-member@example.com", "password")
    visit("/not-visible")
    assert_equal("/", current_path)
    assert(page.has_content?(/is not accessible/i))
  end

  test "check catalog visibility as editor" do
    log_in_as("one-editor@example.com", "password")
    visit("/not-visible")
    assert_equal("/not-visible/en", current_path)
    assert(page.has_content?(/Catalog without visibility/i))
  end

  test "check catalog visibility as super-editor" do
    log_in_as("one-super-editor@example.com", "password")
    visit("/not-visible")
    assert_equal("/not-visible/en", current_path)
    assert(page.has_content?(/Catalog without visibility/i))
  end

  test "check catalog visibility as reviewer" do
    log_in_as("one-reviewer@example.com", "password")
    visit("/not-visible")
    assert_equal("/not-visible/en", current_path)
    assert(page.has_content?(/Catalog without visibility/i))
  end

  test "check catalog visibility as admin" do
    log_in_as("one-admin@example.com", "password")
    visit("/not-visible")
    assert_equal("/not-visible/en", current_path)
    assert(page.has_content?(/Catalog without visibility/i))
  end

  test "check catalog visibility as system-admin" do
    log_in_as("system-admin@example.com", "password")
    visit("/not-visible")
    assert_equal("/not-visible/en", current_path)
    assert(page.has_content?(/Catalog without visibility/i))
  end
end
