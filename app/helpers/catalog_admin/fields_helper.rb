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

  def render_catalog_admin_fields_option_inputs(form)
    model_name = form.object.partial_name
    partial = "catalog_admin/fields/#{model_name}_option_inputs"
    render(partial, :f => form)
  end
end
