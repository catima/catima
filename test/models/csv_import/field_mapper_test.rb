require "test_helper"

class CSVImport::FieldMapperTest < ActiveSupport::TestCase
  test "column_fields" do
    column_fields = mapper.column_fields
    assert_equal(
      %w(name nickname age site email rank wut make),
      column_fields.keys
    )
    assert_nil(column_fields["wut"])
    assert_nil(column_fields["make"])
    assert_equal(fields(:one_author_name), column_fields["name"].field)
    assert_equal(
      fields(:one_author_nickname),
      column_fields["nickname"].field
    )
    assert_equal(fields(:one_author_age), column_fields["age"].field)
    assert_equal(fields(:one_author_site), column_fields["site"].field)
    assert_equal(fields(:one_author_email), column_fields["email"].field)
    assert_equal(fields(:one_author_rank), column_fields["rank"].field)
  end

  test "mapped_fields" do
    mapped_fields = mapper.mapped_fields
    assert_equal(6, mapped_fields.count)
    assert_equal(fields(:one_author_name), mapped_fields.first.field)
    assert_equal(fields(:one_author_nickname), mapped_fields.second.field)
  end

  test "unrecognized_columns" do
    assert_equal(%w(wut make), mapper.unrecognized_columns)
  end

  test "field_for_column with nil column returns nil" do
    nil_mapper = CSVImport::FieldMapper.new(
      item_types(:one_author).all_fields,
      [nil, "name"],
      :en
    )
    assert_nil(nil_mapper.column_fields[nil])
    assert_not_nil(nil_mapper.column_fields["name"])
  end

  test "field_for_column with empty column returns nil" do
    empty_mapper = CSVImport::FieldMapper.new(
      item_types(:one_author).all_fields,
      ["", "name"],
      :en
    )
    assert_nil(empty_mapper.column_fields[""])
    assert_not_nil(empty_mapper.column_fields["name"])
  end

  test "duplicate_mapped_columns detects columns resolving to the same field (different case)" do
    dup_mapper = CSVImport::FieldMapper.new(
      item_types(:one_author).all_fields,
      %w(name Name),
      :en
    )
    duplicates = dup_mapper.duplicate_mapped_columns
    assert_equal(1, duplicates.size)
    assert_includes(duplicates.values.first, "name")
    assert_includes(duplicates.values.first, "Name")
  end

  test "duplicate_mapped_columns detects columns resolving to the same field (same case)" do
    dup_mapper = CSVImport::FieldMapper.new(
      item_types(:one_author).all_fields,
      %w(name name),
      :en
    )
    duplicates = dup_mapper.duplicate_mapped_columns
    assert_equal(1, duplicates.size)
    assert_equal(%w(name name), duplicates.values.first)
  end

  test "duplicate_mapped_columns returns empty hash when no duplicates" do
    assert_empty(mapper.duplicate_mapped_columns)
  end

  test "column_fields with i18n" do
    column_fields = i18n_mapper.column_fields
    assert_equal(["bio", "bio (en)"], column_fields.keys)
    assert_equal(
      fields(:multilingual_author_bio),
      column_fields["bio"].field
    )
    assert_equal(
      fields(:multilingual_author_bio),
      column_fields["bio (en)"].field
    )
    assert_equal("fr", column_fields["bio"].locale.to_s)
    assert_equal("en", column_fields["bio (en)"].locale.to_s)
  end

  test "column_fields with choice set fields" do
    column_fields = choice_set_mapper.column_fields
    assert_equal(
      %w(language-single languages-multiple),
      column_fields.keys
    )
    assert_equal(
      fields(:one_language_field),
      column_fields["language-single"].field
    )
    assert_equal(
      fields(:one_multiple_language_field),
      column_fields["languages-multiple"].field
    )
  end

  test "mapped_fields includes choice set fields" do
    mapped_fields = choice_set_mapper.mapped_fields
    assert_equal(2, mapped_fields.count)
    assert_includes(
      mapped_fields.map(&:field),
      fields(:one_language_field)
    )
    assert_includes(
      mapped_fields.map(&:field),
      fields(:one_multiple_language_field)
    )
  end

  test "column_fields with i18n choice set fields" do
    column_fields = i18n_choice_set_mapper.column_fields
    assert_equal(
      ["language-i18n", "language-i18n (fr)"],
      column_fields.keys
    )
    assert_equal(
      fields(:multilingual_i18n_language_field),
      column_fields["language-i18n"].field
    )
    assert_equal(
      fields(:multilingual_i18n_language_field),
      column_fields["language-i18n (fr)"].field
    )
    # Primary language for multilingual catalog is fr
    assert_equal("fr", column_fields["language-i18n"].locale.to_s)
    assert_equal("fr", column_fields["language-i18n (fr)"].locale.to_s)
  end

  private

  def mapper
    fields = item_types(:one_author).all_fields
    columns = %w(name nickname age site email rank wut make)
    default_locale = :en

    CSVImport::FieldMapper.new(fields, columns, default_locale)
  end

  def i18n_mapper
    fields = item_types(:multilingual_author).all_fields
    columns = ["bio", "bio (en)"]
    default_locale = :fr

    CSVImport::FieldMapper.new(fields, columns, default_locale)
  end

  def choice_set_mapper
    fields = item_types(:one_author).all_fields
    columns = %w[language-single languages-multiple]
    default_locale = :en

    CSVImport::FieldMapper.new(fields, columns, default_locale)
  end

  def i18n_choice_set_mapper
    fields = item_types(:multilingual_author).all_fields
    columns = ["language-i18n", "language-i18n (fr)"]
    default_locale = :fr # multilingual catalog has fr as primary

    CSVImport::FieldMapper.new(fields, columns, default_locale)
  end
end
