module FieldsHelper
  def field_help_text(field, _attribute=:default_value)
    model_key = field.model_name.i18n_key
    t("helpers.help.#{model_key}")
  end

  def field_value(item, field, options={})
    field_presenter(item, field, options).value
  end

  def field_presenter(item, field, options={})
    field = resolve_field(item, field)
    "#{field.class.name}Presenter".constantize.new(self, item, field, options)
  end

  def resolve_field(item, field_or_slug)
    return field_or_slug if field_or_slug.is_a?(Field)
    item.fields.find(-> { fail "Unknown field: #{field_or_slug}" }) do |f|
      f.slug == field_or_slug.to_s
    end
  end
end
