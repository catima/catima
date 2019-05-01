module CatalogAdmin::FieldsOptionHelper
  def primary_option?(field)
    return false if field.is_a?(Category)

    return false unless field.human_readable?

    return false if field.restricted?

    true
  end

  def formatted_option?(field)
    return false unless field.respond_to?(:formatted?)

    return false if field.primary?

    true
  end

  def restricted_option?(field)
    return false if field.primary?

    true
  end
end
