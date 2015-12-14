require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "shows custom home page placeholder" do
    config = Configuration.first!
    config.update!(:root_mode => "custom")

    visit("/")
    assert(page.has_content?(/customize this page/i))
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

  test "shows catalog listing" do
    config = Configuration.first!
    config.update!(:root_mode => "listing")

    visit("/")

    ["nested", "one", "two", "Multilingual", "Reviewed Catalog"].each do |name|
      assert(page.has_selector?("a", :text => name))
    end

    refute(page.has_content?("Inactive Catalog"))
  end

  test "redirects to catalog" do
    config = Configuration.first!
    config.update!(:root_mode => "redirect", :default_catalog => catalogs(:two))

    visit("/")

    assert_equal("/two/en", current_path)
  end
end
