require "test_helper"

class CatalogAdmin::ItemTypesTest < ActionDispatch::IntegrationTest
  test "create an item type" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin")
    click_on("New item type")
    fill_in("Name", :with => "Book")
    fill_in("Name (plural)", :with => "Books")
    fill_in("Slug (plural)", :with => "books")

    assert_difference("catalogs(:two).item_types.count") do
      click_on("Create item type")
    end

    type = catalogs(:two).item_types.where(:slug => "books").first!
    assert_equal("Book", type.name)
    assert_equal("Books", type.name_plural)
  end

  test "edit an item type" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin")
    click_on("Author")
    click_on("Edit name and slug")
    fill_in("Name", :with => "Writer")

    assert_no_difference("catalogs(:two).item_types.count") do
      click_on("Save item type")
    end

    type = item_types(:two_author)
    assert_equal("Writer", type.name)
  end
end
