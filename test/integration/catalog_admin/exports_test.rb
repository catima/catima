require "test_helper"

class CatalogAdmin::ExportsTest < ActionDispatch::IntegrationTest
  test "create a catima export" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/_exports")

    first("button", :text => "New export (choose format)").click
    first("a", :text => "Catima").click

    assert(page.has_content?("New catima export"))

    assert_difference("Export.count", + 1) do
      uncheck("Add files")
      click_on("Create export")
    end

    assert(page.has_content?("two-admin@example.com"))
    assert(page.has_content?("processing"))
    assert(page.has_content?("valid"))
  end

  test "create a csv export without csv-specific options" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/_exports")

    first("button", :text => "New export (choose format)").click
    first("a", :text => "Csv").click

    assert(page.has_checked_field?("Add files"))
    assert(page.has_unchecked_field?("Include Catima ID"))
    assert(page.has_unchecked_field?("Use field slugs as column headers"))

    assert_difference("Export.count", +1) do
      click_on("Create export")
    end

    export = Export.last
    assert_equal("csv", export.category)
    assert(export.with_files)
    refute(export.with_catima_id)
    refute(export.use_slugs)
  end

  test "create a csv export with catima id and slugs options" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/_exports")

    first("button", :text => "New export (choose format)").click
    first("a", :text => "Csv").click

    assert_difference("Export.count", +1) do
      check("Include Catima ID")
      check("Use field slugs as column headers")
      click_on("Create export")
    end

    export = Export.last
    assert(export.with_catima_id)
    assert(export.use_slugs)
  end

  test "csv-specific options are not shown for non-csv exports" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/_exports")

    first("button", :text => "New export (choose format)").click
    first("a", :text => "Catima").click

    refute(page.has_field?("Include Catima ID"))
    refute(page.has_field?("Use field slugs as column headers"))
  end
end
