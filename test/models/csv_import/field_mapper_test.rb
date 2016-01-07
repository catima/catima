require "test_helper"

class CSVImport::FieldMapperTest < ActiveSupport::TestCase
  test "column_fields" do
    column_fields = mapper.column_fields
    assert_equal(%w(name nickname age wut make), column_fields.keys)
    assert_nil(column_fields["age"])
    assert_nil(column_fields["wut"])
    assert_nil(column_fields["make"])
    assert_equal(fields(:one_author_name), column_fields["name"].__getobj__)
    assert_equal(
      fields(:one_author_nickname),
      column_fields["nickname"].__getobj__
    )
  end

  test "mapped_fields" do
    mapped_fields = mapper.mapped_fields
    assert_equal(2, mapped_fields.count)
    assert_equal(fields(:one_author_name), mapped_fields.first.__getobj__)
    assert_equal(fields(:one_author_nickname), mapped_fields.second.__getobj__)
  end

  test "column_fields with i18n" do
    column_fields = i18n_mapper.column_fields
    assert_equal(["bio", "bio (en)"], column_fields.keys)
    assert_equal(
      fields(:multilingual_author_bio),
      column_fields["bio"].__getobj__
    )
    assert_equal(
      fields(:multilingual_author_bio),
      column_fields["bio (en)"].__getobj__
    )
    assert_equal("fr", column_fields["bio"].locale.to_s)
    assert_equal("en", column_fields["bio (en)"].locale.to_s)
  end

  private

  def mapper
    fields = item_types(:one_author).all_fields
    columns = %w(name nickname age wut make)
    default_locale = :en

    CSVImport::FieldMapper.new(fields, columns, default_locale)
  end

  def i18n_mapper
    fields = item_types(:multilingual_author).all_fields
    columns = ["bio", "bio (en)"]
    default_locale = :fr

    CSVImport::FieldMapper.new(fields, columns, default_locale)
  end
end
