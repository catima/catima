require "test_helper"

class CatalogAdmin::FieldsCreatorTest < ActionDispatch::IntegrationTest
  test "add a editor field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/en/admin/authors/fields")
    click_on("Editor field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end
  end
end
