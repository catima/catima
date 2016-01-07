# A column in a CSV file represents values for a particular Field. But for an
# i18n Field, it also represents the values for a certain language. So we can
# think of a column's identity as a Field + Locale combination. This class
# decorates Field to add a `locale` property in to encapsulate that concept.
#
class CSVImport::FieldWithLocale < SimpleDelegator
  attr_accessor :locale

  def initialize(field, locale)
    super(field)
    @locale = locale
  end

  # Returns the accessor name for reading the value of this Field from an Item.
  # Normally this is just the Field's UUID, but in the case of an i18n Field,
  # it is UUID plus the `_<locale>` suffix.
  def attribute_name
    i18n? ? "#{uuid}_#{locale}" : uuid
  end
end
