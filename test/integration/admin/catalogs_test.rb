require "test_helper"

class Admin::CatalogsTest < ActionDispatch::IntegrationTest
  test "create a catalog" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")
    click_on("New catalog")
    fill_in("Name", :with => "Integration test catalog")
    fill_in("Slug", :with => "int-test-catalog")
    select("Italiano", :from => "Primary language")
    check("Deutsch")
    check("Français")
    check("Requires review")

    assert_difference("Catalog.count") do
      click_on("Create catalog")
    end

    catalog = Catalog.where(:slug => "int-test-catalog").first!
    assert_equal("it", catalog.primary_language)
    assert_equal(%w(de fr), catalog.other_languages)
    assert(catalog.requires_review?)
  end

  test "edit a catalog" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")
    first("a.catalog-action-edit").click
    fill_in("Name", :with => "Changed by test")

    assert_difference("Catalog.where(:name => 'Changed by test').count") do
      click_on("Save catalog")
    end
  end

  test "deactivate a catalog" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")

    assert_difference("Catalog.active.count", -1) do
      first("a.catalog-action-deactivate").click
    end
  end

  test "reactivate a catalog" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")

    assert_difference("Catalog.active.count") do
      first("a.catalog-action-reactivate").click
    end
  end

  test "delete a catalog" do
    log_in_as("system-admin@example.com", "password")
    visit("/admin")

    assert_difference("Catalog.active.count", -1) do
      find("td", :text => "Catalog to be destroyed").find(:xpath, '..').first("a.catalog-action-delete").click
    end
  end
end
