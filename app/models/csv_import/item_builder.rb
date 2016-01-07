class CSVImport::ItemBuilder
  attr_reader :row, :column_fields, :item, :failure

  def initialize(row, column_fields, item)
    @row = row
    @column_fields = column_fields
    @item = item.behaving_as_type
  end

  def assign_row_values
    row.each do |column, value|
      field = column_fields[column]
      next if field.nil?

      item.public_send("#{field.attribute_name}=", value)
    end
  end

  def valid?
    # TODO
    @failure = nil
    true
  end
end
