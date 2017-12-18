require "test_helper"

class CatalogAdmin::CategoriesTest < ActionDispatch::IntegrationTest
  test "create a category" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin")
    click_on("New category")
    fill_in("Name", :with => "Bicycle")

    assert_difference("catalogs(:two).categories.count") do
      click_on("Create category")
    end
  end

  test "edit a category" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Category One")
    click_on("Edit category")
    fill_in("Name", :with => "Edited by test")

    assert_no_difference("catalogs(:two).categories.count") do
      click_on("Save category")
    end

    category = categories(:one)
    assert_equal("Edited by test", category.name)
  end

  test "delete a category" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Category One")
    click_on("Edit category")

    assert_difference("catalogs(:one).categories.count", -1) do
      click_on("Delete this category")
    end

    category = categories(:one)
    refute(category.active?)
  end
end
