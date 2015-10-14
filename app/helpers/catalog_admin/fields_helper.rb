module CatalogAdmin::FieldsHelper
  def field_style_select(form)
    form.collection_select(
      :style,
      Field::STYLE_CHOICES.keys,
      :itself,
      ->(key) { Field::STYLE_CHOICES[key] },
      :hide_label => true
    )
  end
end
