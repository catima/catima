require "test_helper"

class Admin::ConfigurationsTest < ActionDispatch::IntegrationTest
  test "change root behavior to listing" do
    config = Configuration.first!
    config.update!(:root_mode => "custom")

    log_in_as("system-admin@example.com", "password")
    visit("admin")
    select("Catalog list (default)", :from => "configuration[root_mode]")
    click_on("Save")

    assert_equal("listing", config.reload.root_mode)
  end

  test "change root behavior to custom" do
    config = Configuration.first!
    config.update!(:root_mode => "listing")

    log_in_as("system-admin@example.com", "password")
    visit("admin")
    select("Custom", :from => "configuration[root_mode]")
    click_on("Save")

    assert_equal("custom", config.reload.root_mode)
  end

  test "change root behavior to redirect" do
    config = Configuration.first!
    config.update!(:root_mode => "listing")

    log_in_as("system-admin@example.com", "password")
    visit("admin")
    select("Redirect to a catalog", :from => "configuration[root_mode]")
    select("Multilingual", :from => "configuration[default_catalog_id]")
    click_on("Save")

    assert_equal("redirect", config.reload.root_mode)
    assert_equal(catalogs(:multilingual), config.default_catalog)
  end
end
