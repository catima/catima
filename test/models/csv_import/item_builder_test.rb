require "test_helper"

class CSVImport::ItemBuilderTest < ActiveSupport::TestCase
  test "assign_row_values" do
    item = item_types(:one_author).items.build
    row = { "name" => "Hey There!", "ignore" => "What" }
    column_fields = { "name" => fields_with_locale(:one_author_name) }

    builder = CSVImport::ItemBuilder.new(row, column_fields, item)
    builder.assign_row_values

    assert_equal("Hey There!", item.behaving_as_type.one_author_name_uuid)
  end

  private

  def fields_with_locale(fixture_name, locale=I18n.locale)
    CSVImport::FieldWithLocale.new(fields(fixture_name), locale)
  end
end
