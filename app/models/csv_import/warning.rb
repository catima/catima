# Represents a warning that occurred during CSV import. Unlike failures,
# warnings don't prevent the row from being imported, but alert the user
# to potential issues or ambiguities.
#
class CSVImport::Warning
  attr_reader :row, :column, :message, :details, :line_number

  def initialize(row, column, message, details={}, line_number=nil)
    @row = row
    @column = column
    @message = message
    @details = details
    @line_number = line_number
  end

  def to_s
    # Format warnings
    "#{column}: #{message}"
  end
end
