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
  attr_reader :row, :column_fields, :item, :failure

  def initialize(row, column_fields, item)
    @row = row
    @column_fields = column_fields
    @item = item.behaving_as_type
  end

  # For each column in the row, find the matching Field (if any) and assign the
  # value of that column to the Item for that Field.
  def assign_row_values
    row.each do |column, value|
      field = column_fields[column]
      next if field.nil?

      item.public_send("#{field.attribute_name}=", value)
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
    # TODO
    @failure = nil
    true
  end

  # Saves the underlying Item record to the database, raising an exception if
  # something goes wrong. Normal ActiveRecord validations are skipped, so take
  # care to explicitly check `valid?` before calling `save!`.
  def save!
    item.save!(:validate => false)
  end
end
