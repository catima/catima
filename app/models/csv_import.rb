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
