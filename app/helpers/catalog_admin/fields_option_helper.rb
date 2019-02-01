module CatalogAdmin::FieldsOptionHelper
  def primary_option?(field)
    # TODO: remove the condition below when there is no longer formatted text primary fields in production
    if field.respond_to?(:formatted?)
      return false if field.formatted?
    end

    return false if field.is_a?(Category)

    return false unless field.human_readable?

    true
  end

  def formatted_option?(field)
    return false unless field.respond_to?(:formatted?)

    return false if field.primary?

    true
  end
end
