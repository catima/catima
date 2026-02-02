# Processes CSV values for reference fields during import. This class handles:
#
# * Parsing pipe-separated (|) item IDs from CSV values
# * Validating that IDs are integers
# * Verifying that referenced items exist in the related item type
# * Returning item IDs (single or array) for assignment to items
# * Collecting errors for invalid IDs or non-existent items
#
class CSVImport::ReferenceValueProcessor
  SEPARATOR = '|'.freeze

  attr_reader :field, :related_item_type, :catalog, :errors

  def initialize(field)
    @field = field
    @related_item_type = field.related_item_type
    @catalog = field.catalog
    @errors = []
  end

  # Processes a CSV value (string) and returns the appropriate value for
  # assignment to an item.
  #
  # For single reference fields: returns an integer ID
  # For multiple reference fields: returns an array of string IDs
  #
  # Validates that IDs are integers and that referenced items exist.
  #
  def process(csv_value)
    return nil if csv_value.blank?

    ids = parse_ids(csv_value)
    return nil if ids.empty?

    valid_ids = validate_and_filter_ids(ids)
    return nil if valid_ids.empty?

    field.multiple? ? valid_ids : valid_ids.first.to_i
  end

  private

  def parse_ids(csv_value)
    csv_value.split(SEPARATOR).map(&:strip).compact_blank
  end

  def validate_and_filter_ids(ids)
    valid_ids = []

    ids.each do |id_str|
      # Validate that the ID is an integer
      unless id_str.match?(/\A\d+\z/)
        add_error(I18n.t(
                    'catalog_admin.csv_imports.create.invalid_reference_id',
                    id: id_str
                  ))
        next
      end

      id = id_str.to_i

      # Check if the item exists in the related item type
      unless item_exists?(id)
        add_error(I18n.t(
                    'catalog_admin.csv_imports.create.reference_item_not_found',
                    id: id,
                    item_type: related_item_type.name
                  ))
        next
      end

      valid_ids << id.to_s
    end

    valid_ids
  end

  def item_exists?(id)
    # Check if item exists using a simple query
    related_item_type.items.exists?(id)
  end

  def add_error(message)
    @errors << message
  end
end
