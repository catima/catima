# Represents a CSV row that was skipped in the import process due to one or
# more validation failures. The `column_errors` property is a Hash of:
# `"column name" => ["error messages"]`. Columns without errors will still be
# present in the Hash, but will have an empty Array for a value.
#
class CSVImport::Failure
  attr_reader :row, :column_errors

  def initialize(row, column_errors)
    @row = row
    @column_errors = column_errors.with_indifferent_access
  end
end
