# CSVImport is a Form object that allows a user to upload a CSV file and import
# its rows as new Item records. The columns in the CSV are mapped to particular
# Fields, and each row is validated before being imported.
#
# For specific rules and more details about the import behavior, refer to the
# documentation in the following helper classes:
#
# * CSVImport::Reader
# * CSVImport::FieldMapper
# * CSVImport::ItemBuilder
#
# To use CSVImport, a controller must set the following attributes:
#
# * file (the CSV file uploaded by the user, must have a .csv extension)
# * item_type (the ItemType that the created Items will belong to)
# * creator (the User that will be recorded as the creator of each Item)
#
# The controller should then call `save` to perform the import.
#
# The results of the import are made available in two properties:
#
# * success_count (number of rows that were successfully imported as new Items)
# * failures (an Array of CSVImport::Failure object representing skipped rows)
#
# The following properties are also available to display in the UI:
#
# * encoding (the character encoding used to interpret the CSV file)
# * columns (all column names as parsed from the CSV)
# * unrecognized_columns (the column names that could not be mapped)
#
class CSVImport < ActiveType::Object
  attr_accessor :creator
  attr_accessor :item_type
  attribute :file_id
  attribute :filename
  attribute :size, :integer

  attr_reader :failures, :success_count

  attachment :file, :extension => "csv"

  delegate :all_fields, :catalog, :to => :item_type
  delegate :primary_language, :to => :catalog
  delegate :encoding, :rows, :to => :reader
  delegate :column_fields, :mapped_fields, :unrecognized_columns,
           :to => :field_mapper

  before_save :process_import

  def initialize(*)
    super
    @failures = []
    @success_count = 0
  end

  def columns
    rows.first.headers
  end

  private

  attr_writer :success_count

  def process_import
    Item.transaction do
      rows.each do |row|
        builder = CSVImport::ItemBuilder.new(row, column_fields, build_item)
        builder.assign_row_values
        validate_and_save_item(builder)
      end
    end
    true
  end

  def validate_and_save_item(builder)
    if builder.valid?
      builder.save!
      self.success_count += 1
    else
      failures << builder.failure
    end
  end

  def build_item
    Item.new(
      :item_type => item_type,
      :catalog => catalog,
      :creator => creator
    ).behaving_as_type
  end

  def field_mapper
    @field_mapper ||= CSVImport::FieldMapper.new(
      item_type.all_fields,
      columns,
      item_type.catalog.primary_language
    )
  end

  def reader
    @reader ||= CSVImport::Reader.new(file)
  end
end
