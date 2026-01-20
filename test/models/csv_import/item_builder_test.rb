require "test_helper"

class CSVImport::ItemBuilderTest < ActiveSupport::TestCase
  test "assign_row_values" do
    item = item_types(:one_author).items.build

    row = {
      "name" => "Hey There!",
      "age" => "25",
      "site" => "https://google.com",
      "email" => "test@example.com",
      "rank" => "1.95",
      "ignore" => "What"
    }
    column_fields = {
      "name" => fields_with_locale(:one_author_name),
      "age" => fields_with_locale(:one_author_age),
      "site" => fields_with_locale(:one_author_site),
      "email" => fields_with_locale(:one_author_email),
      "rank" => fields_with_locale(:one_author_rank)
    }

    builder = CSVImport::ItemBuilder.new(row, column_fields, item)
    builder.assign_row_values

    item = item.behaving_as_type
    assert_equal("Hey There!", item.one_author_name_uuid)
    assert_equal("25", item.one_author_age_uuid)
    assert_equal("https://google.com", item.one_author_site_uuid)
    assert_equal("test@example.com", item.one_author_email_uuid)
    assert_equal("1.95", item.one_author_rank_uuid)
    assert(builder.valid?)
  end

  test "valid? only checks fields in column mapping" do
    item = item_types(:one_author).items.build
    row = { "name" => "" }
    column_fields = { "name" => fields_with_locale(:one_author_name) }

    builder = CSVImport::ItemBuilder.new(row, column_fields, item)
    builder.assign_row_values

    refute(builder.valid?)

    failure = builder.failure
    refute_nil(failure)
    assert_equal(row, failure.row)
    assert_equal({ "name" => ["can't be blank"] }, failure.column_errors)
  end

  test "assign_row_values with choice set field - single choice" do
    item = item_types(:one_author).items.build

    row = {
      "name" => "Test Author",
      "language-single" => "Eng"
    }
    column_fields = {
      "name" => fields_with_locale(:one_author_name),
      "language-single" => fields_with_locale(:one_language_field)
    }

    builder = CSVImport::ItemBuilder.new(row, column_fields, item)
    builder.assign_row_values

    item = item.behaving_as_type
    assert_equal("Test Author", item.one_author_name_uuid)
    assert_equal(choices(:one_english).id, item.one_language_field_uuid)
    assert(builder.valid?)
  end

  test "assign_row_values with choice set field - multiple choices" do
    item = item_types(:one_author).items.build

    row = {
      "name" => "Test Author",
      "languages-multiple" => "Eng|Spanish"
    }
    column_fields = {
      "name" => fields_with_locale(:one_author_name),
      "languages-multiple" => fields_with_locale(:one_multiple_language_field)
    }

    builder = CSVImport::ItemBuilder.new(row, column_fields, item)
    builder.assign_row_values

    item = item.behaving_as_type
    assert_equal("Test Author", item.one_author_name_uuid)
    assert_equal(
      [choices(:one_english).id, choices(:one_spanish).id],
      item.one_multiple_language_field_uuid
    )
    assert(builder.valid?)
  end

  test "assign_row_values with choice set field - creates new choice" do
    item = item_types(:one_author).items.build

    row = {
      "name" => "Test Author",
      "language-single" => "Italian"
    }
    column_fields = {
      "name" => fields_with_locale(:one_author_name),
      "language-single" => fields_with_locale(:one_language_field)
    }

    builder = CSVImport::ItemBuilder.new(row, column_fields, item)

    assert_difference "Choice.count", 1 do
      builder.assign_row_values
    end

    item = item.behaving_as_type
    new_choice = Choice.order(:created_at).last
    assert_equal("Italian", new_choice.short_name_en)
    assert_equal(new_choice.id, item.one_language_field_uuid)
  end

  private

  def fields_with_locale(fixture_name, locale=I18n.locale)
    CSVImport::FieldWithLocale.new(fields(fixture_name), locale)
  end
end
