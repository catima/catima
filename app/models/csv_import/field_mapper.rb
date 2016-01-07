class CSVImport::FieldMapper
  attr_reader :fields, :columns, :default_locale

  def initialize(fields, columns, default_locale)
    @fields = fields
    @columns = columns
    @default_locale = default_locale
  end

  def column_fields
    @column_fields ||= begin
      columns.each_with_object({}) do |column, hash|
        hash[column] = field_for_column(column)
      end
    end
  end

  def mapped_fields
    column_fields.values.compact
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
