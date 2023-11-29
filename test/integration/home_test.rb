require "test_helper"

class HomeTest < ActionDispatch::IntegrationTest
  test "shows custom home page placeholder" do
    config = Configuration.first!
    config.update!(:root_mode => "custom")

    visit("/")
    assert(page.has_content?(/customize this page/i))
  end

  test "shows catalog listing" do
    config = Configuration.first!
    config.update!(:root_mode => "listing")

    visit("/")
    assert_listing_content
  end

  test "redirects to catalog" do
    config = Configuration.first!
    config.update!(:root_mode => "redirect", :default_catalog => catalogs(:two))

    visit("/")

    assert_equal("/two/en", current_path)
  end

  test "doesn't redirect to inactive catalog" do
    config = Configuration.first!
    config.update!(
      :root_mode => "redirect",
      :default_catalog => catalogs(:inactive)
    )

    visit("/")
    assert_equal("/", current_path)
    assert_listing_content
  end

  private

  def assert_listing_content
    ["nested", "one", "two", "Multilingual", "Reviewed Catalog"].each do |name|
      assert(page.has_selector?("a", :text => name))
    end

    refute(page.has_content?("Inactive Catalog"))
  end
end
