require "test_helper"

class CatalogAdmin::CategoriesFieldsTest < ActionDispatch::IntegrationTest
  test "add an int field" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin")
    click_on("Category One")
    click_on("Integer field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    fill_in("Minimum value (optional)", :with => 3)
    fill_in("Maximum value (optional)", :with => 50)

    assert_difference("categories(:one).fields.count") do
      click_on("Create field")
    end

    field = categories(:one).fields.where(:slug => "test").first!
    assert_equal(3, field.minimum.to_i)
    assert_equal(50, field.maximum.to_i)
  end

  test "edit a field" do
    log_in_as("nested-admin@example.com", "password")
    visit("/nested/en/admin")
    click_on("Bicycle")
    first("a.field-action-edit").click
    fill_in("field[name_en]", :with => "Changed!")
    fill_in("Slug", :with => "changed")

    assert_no_difference("Field.count") do
      click_on("Save field")
    end

    field = categories(:nested_bicycle).fields.where(:slug => "changed").first!
    assert_equal("Changed!", field.name)
  end

  test "delete a field" do
    log_in_as("nested-admin@example.com", "password")
    visit("/nested/en/admin")
    click_on("Bicycle")

    assert_difference("categories(:nested_bicycle).fields.count", -1) do
      first("a.field-action-delete").click
    end
  end
end
