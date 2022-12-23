module CatalogAdmin::FieldsOptionHelper
  def primary_option?(field)
    return false if field.is_a?(Category)

    return false unless could_be_human_readable(field)

    true
  end

  def display_in_public_list_option?(field)
    could_be_human_readable(field)
  end

  def formatted_option?(field)
    field.respond_to?(:formatted?)
  end

  private

  def could_be_human_readable(field)
    field.is_a?(Field::Text) || field.human_readable?
  end
end
