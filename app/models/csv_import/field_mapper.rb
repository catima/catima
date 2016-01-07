# Part of importing a CSV is mapping the CSV column names to the corresponding
# Fields in our database. This class handles that mapping. It works as follows:
#
# * The CSV column name should exactly match the slug of the desired Field.
#
# * If the column name contains spaces or other non-slug characters, the column
#   name is first converted to lower case and those characters replaced by
#   hyphens. Then the slug match is attempted.
#
# * For Fields that use i18n, by default the column will be assumed to be for
#   the catalog's primary language. To explicitly specify the desired language
#   for the column, the name of the column should be in the format:
#   `<slug> (<locale>)`. E.g. `biography (fr)` would match the Field with the
#   slug "biography" and use the values of that column as the French
#   localization for that Field.
#
# Any columns that cannot be mapped are ignored. These ignored columns can be
# obtained by calling `unrecognized_columns`.
#
# CURRENTLY ONLY TEXT FIELDS ARE ELIGIBLE FOR MAPPING. Other Field types (int,
# reference, xref, choice set, etc.) are ignored.
#
class CSVImport::FieldMapper
  attr_reader :fields, :columns, :default_locale

  def initialize(fields, columns, default_locale)
    @fields = fields
    @columns = columns
    @default_locale = default_locale
  end

  # A Hash of column names to the Field object that it maps to. The Field is
  # actually a FieldWithLocale that decorates the underlying Field.
  def column_fields
    @column_fields ||= begin
      columns.each_with_object({}) do |column, hash|
        hash[column] = field_for_column(column)
      end
    end
  end

  # An Array of all FieldWithLocale objects that were found by the mapping.
  def mapped_fields
    column_fields.values.compact
  end

  # An Array of column names that could not be mapped.
  def unrecognized_columns
    column_fields.select { |_, f| f.nil? }.map(&:first)
  end

  private

  def field_for_column(column)
    column, locale = parse_localized_column(column)
    column_as_slug = column.strip.downcase.gsub(/[^a-z0-9]+/, "-")
    field_with_slug(column_as_slug, locale || default_locale)
  end

  def field_with_slug(slug, locale=primary_language)
    field = fields.find { |f| f.slug == slug }
    # TODO: remove this restriction
    return nil unless field.is_a?(Field::Text)

    CSVImport::FieldWithLocale.new(field, locale) unless field.nil?
  end

  def parse_localized_column(column)
    column.match(/^(.+?)(?:\s*\(\s*(\w{2})\s*\))?\s*$/)[1..2]
  end
end
