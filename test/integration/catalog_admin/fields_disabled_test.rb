require "test_helper"

class CatalogAdmin::FieldsDisabledTest < ActionDispatch::IntegrationTest
  setup { use_javascript_capybara_driver }

  test "fields are correctly disabled" do
    log_in_as("one-admin@example.com", "password")

    visit("/one/en/admin/authors/fields/nickname/edit")

    # "Include this field in site list view" is checked by default.
    assert find("#field_formatted_text").disabled?

    uncheck("Include this field in site list view")
    check("Use this as the primary field")
    assert find("#field_restricted").disabled?
    assert find("#field_formatted_text").disabled?

    uncheck("Use this as the primary field")
    check("Restrict this field to catalog staff")
    assert find("#field_primary").disabled?

    uncheck("Restrict this field to catalog staff")
    check("Has formatted text")
    assert find("#field_primary").disabled?
    assert find("#field_display_in_public_list").disabled?
  end
end
