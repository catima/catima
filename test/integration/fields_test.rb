require "test_helper"

class FieldsTest < ActionDispatch::IntegrationTest

  include ItemReferenceHelper

  test "create and view item with a compound field" do
    log_in_as("one-admin@example.com", "password")
    visit("/one/en/admin/authors/fields")

    click_on("Compound field")
    fill_in("field[name_en]", :with => "Test")
    fill_in("field[name_plural_en]", :with => "Tests")
    fill_in("Slug (singular)", :with => "test")
    first('input#field_template', visible: false).set('{"en":"{{name}}:{{age}}"}')
    click_on("Create field")

    visit("/one/en/authors")
    click_on("Stephen King")
    assert(page.has_content?("Stephen King:68"))
  end
end
