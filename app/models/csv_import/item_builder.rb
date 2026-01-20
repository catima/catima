# Given a row (Hash of column name => value), a mapping of column names to
# Fields, and an Item, this class takes care of assigning CSV values to the
# Item and saving it to the database. This class is fairly simple because most
# of the heavy lifting is done by other components like the FieldMapper class.
#
# The most interesting aspect of the ItemBuilder is its validation behavior.
# We want to allow a CSV import to succeed even some of the required Fields are
# missing. Therefore the normal validation process is skipped when the Item
# record is saved to the database.
#
# However, for those Fields that *are* present in the CSV, we want to ensure
# validation passes for those. That is the purpose of the `valid?` method.
#
# So the process of importing is to call `assign_row_values`, then call `valid?`
# to check that the assigned values are acceptable, and then `save!` to persist
# the Item (skipping validation of Fields that weren't specified in the CSV).
#
# If `valid?` fails (i.e. returns false), then the `failure` property will
# contain an explanation of why the row was invalid.
#
# For example, consider a "Person" ItemType that has two required fields:
# "first_name" and "last_name". A user may import from a CSV that contains only
# a "first_name" column. As long as those first names are acceptable, the import
# will succeed. Since "last_name" was omitted from the CSV, its validation rules
# are not applied.
#
class CSVImport::ItemBuilder
  attr_reader :row, :column_fields, :item, :failure, :warnings

  def initialize(row, column_fields, item)
    @row = row
    @column_fields = column_fields
    @item = item.behaving_as_type
    @warnings = []
  end

  # For each column in the row, find the matching Field (if any) and assign the
  # value of that column to the Item for that Field.
  def assign_row_values
    # Group columns by field to handle choice set fields with multiple locales
    grouped_columns = group_columns_by_field

    grouped_columns.each do |field, columns_with_locales|
      # For choice set fields with multiple locale columns, process all locales together
      if field.is_a?(Field::ChoiceSet) && columns_with_locales.size > 1
        process_multilingual_choice_set_field(field, columns_with_locales)
      else
        # For other fields or single-column choice sets, process each column separately
        columns_with_locales.each do |column, field_with_locale|
          value = row[column]

          # For choice set fields, process the value to convert choice names to IDs
          if field_with_locale.is_a?(Field::ChoiceSet)
            processor = CSVImport::ChoiceSetValueProcessor.new(
              field_with_locale.field,
              field_with_locale.locale
            )
            value = processor.process(value)

            # Collect any warnings from the processor
            collect_processor_warnings(column, processor)
          end

          item.public_send("#{field_with_locale.attribute_name}=", value)
        end
      end
    end
  end

  # For each Field that exists in the column to Field mapping, check that the
  # validation rules pass for that Field's value. This delegates to the rules
  # (e.g. required, min/max length, etc.) defined by each Field.
  #
  # If any of these rules fail, then this method returns false and the `failure`
  # property is set to an `CSVImport::Failure` object explaining the reason.
  #
  def valid?
    @failure = nil

    item.validate
    column_errors = collect_column_errors

    if column_errors.values.flatten.any?
      @failure = CSVImport::Failure.new(row, column_errors)
    end

    ! @failure
  end

  # Saves the underlying Item record to the database, raising an exception if
  # something goes wrong. Normal ActiveRecord validations are skipped, so take
  # care to explicitly check `valid?` before calling `save!`.
  def save!
    item.save!(:validate => false)
  end

  private

  # Group columns by their underlying field
  def group_columns_by_field
    grouped = {}
    column_fields.each do |column, field_with_locale|
      next if field_with_locale.nil?

      field = field_with_locale.field
      grouped[field] ||= {}
      grouped[field][column] = field_with_locale
    end
    grouped
  end

  # Process choice set fields that have multiple locale columns in the CSV
  # (e.g., "language (en)" and "language (fr)")
  # Creates/finds a single choice with all provided translations
  def process_multilingual_choice_set_field(field, columns_with_locales)
    # Collect all locale values from the CSV row
    locale_values = {}
    columns_with_locales.each do |column, field_with_locale|
      value = row[column]
      next if value.blank?

      locale_values[field_with_locale.locale] = value
    end

    return if locale_values.empty?

    # Use the processor to create/find choices with all translations
    processor = CSVImport::ChoiceSetValueProcessor.new(field, nil)
    choice_ids = processor.process_i18n(locale_values)

    # Collect warnings from all processed columns
    columns_with_locales.each_key do |column|
      collect_processor_warnings(column, processor)
    end

    # Assign the choice ID(s) to the item using the field's UUID directly
    item.public_send("#{field.uuid}=", choice_ids)
  end

  def collect_processor_warnings(column, processor)
    processor.warnings.each do |warning_data|
      case warning_data[:type]
      when :ambiguous_choice
        message = I18n.t(
          'catalog_admin.csv_imports.create.multiple_choices_found',
          choice_name: warning_data[:choice_name],
          count: warning_data[:count],
          selected_choice_id: warning_data[:selected_choice_id]
        )

        @warnings << CSVImport::Warning.new(row, column, message, warning_data)
      end
    end
  end

  def collect_column_errors
    column_fields.to_h do |column, field|
      errors = field ? item.errors[field.attribute_name] : []
      [column, errors]
    end
  end
end
