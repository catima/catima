require "test_helper"

class CatalogAdmin::FieldsTest < ActionDispatch::IntegrationTest
  test "add a text field" do
    log_in_as("two-admin@example.com", "password")
    visit("/two/admin/item-types/authors/fields")
    click_on("Text field")
    fill_in("Name", :with => "Birthplace")
    fill_in("Name (plural)", :with => "Birthplaces")
    fill_in("Slug (singular)", :with => "birthplace")
    check("Use this as the primary field for Authors")
    select("Single value – required", :from => "field_text[style]")
    fill_in("Minimum length (optional)", :with => 3)
    fill_in("Maximum length (optional)", :with => 50)

    assert_difference("item_types(:two_author).fields.count") do
      click_on("Create field")
    end

    field = item_types(:two_author).fields.where(:slug => "birthplace").first!
    assert_equal(3, field.minimum.to_i)
    assert_equal(50, field.maximum.to_i)
    assert_equal("Birthplace", field.name)
    assert_equal("Birthplaces", field.name_plural)
    assert(field.display_in_list?)
    assert(field.primary?)
    assert(field.required?)
    refute(field.multiple?)
  end
end
