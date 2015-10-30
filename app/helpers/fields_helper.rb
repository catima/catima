module FieldsHelper
  def field_help_text(field, _attribute=:default_value)
    model_key = field.model_name.i18n_key
    t("helpers.help.#{model_key}")
  end

  def field_value(item, field, options={})
    field_presenter(item, field, options).value
  end

  def field_presenter(item, field, options={})
    "#{field.class.name}Presenter".constantize.new(self, item, field, options)
  end
end
