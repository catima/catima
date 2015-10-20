module FieldsHelper
  def field_help_text(field, _attribute=:default_value)
    model_key = field.model_name.i18n_key
    t("helpers.help.#{model_key}")
  end

  def field_value(item, field)
    field_presenter(item, field).value
  end

  def field_presenter(item, field)
    "#{field.class.name}Presenter".constantize.new(self, item, field)
  end
end
