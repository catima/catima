# A column in a CSV file represents values for a particular Field. But for an
# i18n Field, it also represents the values for a certain language. So we can
# think of a column's identity as a Field + Locale combination. This class
# wraps a Field to add a `locale` property to encapsulate that concept.
#
class CSVImport::FieldWithLocale
  attr_reader :field, :locale

  delegate :uuid, :slug, :i18n?, :multiple?, :choice_set, :catalog, to: :field

  def initialize(field, locale)
    @field = field
    @locale = locale
  end

  # Returns the accessor name for reading the value of this Field from an Item.
  # Normally this is just the Field's UUID, but in the case of an i18n Field,
  # it is UUID plus the `_<locale>` suffix.
  def attribute_name
    i18n? ? "#{uuid}_#{locale}" : uuid
  end

  # Delegate type checking to the underlying field
  delegate :is_a?, to: :field
  delegate :kind_of?, to: :field
end
