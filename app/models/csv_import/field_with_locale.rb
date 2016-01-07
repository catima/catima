class CSVImport::FieldWithLocale < SimpleDelegator
  attr_accessor :locale

  def initialize(field, locale)
    super(field)
    @locale = locale
  end

  def attribute_name
    i18n? ? "#{uuid}_#{locale}" : uuid
  end
end
