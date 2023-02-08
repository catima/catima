module CatalogAdmin::FieldsOptionHelper
  def primary_option?(field)
    return false if field.is_a?(Category)

    return false unless could_be_human_readable(field)

    true
  end

  def display_in_public_list_option?(field)
    return true if could_be_human_readable(field)

    # Image fields can always be listed in public field, although they're
    # not human readable.
    return true if field.is_a?(Field::Image)

    return true if field.filterable?

    false
  end

  def formatted_option?(field)
    field.respond_to?(:formatted?)
  end

  private

  def could_be_human_readable(field)
    # Text fields can be human readable or not depending on whether it
    # represents a formatted value. To be consistent when displaying fields
    # options, we always treat it as human readable.
    return true if field.is_a?(Field::Text)

    field.human_readable?
  end
end
