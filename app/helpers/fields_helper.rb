module FieldsHelper
  def field_help_text(field, attribute=:default_value)
    model_key = field.model_name.i18n_key
    t(attribute, :scope => "helpers.help.#{model_key}")
  end
end
