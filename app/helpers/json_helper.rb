module JsonHelper
  def json_react_display_component(item, field, props={})
    props = json_display_props(item, field).merge(props)
    react_component(field.display_component, props: props, prerender: false)
  end

  def json_react_input_component(form, field, props={})
    props = props.merge(:input => "##{json_hidden_field_id(form, field)}")
    html = [
      json_hidden_field(form, field),
      react_component(field.editor_component, props: props, prerender: false)
    ]
    safe_join(html)
  end

  def json_hidden_field(form, field, options={})
    method = "#{field.uuid}_json"
    id = json_hidden_field_id(form, field)
    data = options.fetch(:data, {}).merge(json_input_data(field))
    data = data.reverse_merge("field-category" => field.category_id) if field.belongs_to_category?
    form.hidden_field(method, options.merge(:data => data, :id => id))
  end

  def json_display_props(item, field)
    json_input_data(field).merge(:value => field.raw_json_value(item))
  end

  def json_input_data(field)
    {
      :field_uuid => field.uuid,
      :field_options => field.options,
      :field_type => field.short_type_name,
      :field_label => field.label,
      :field_required => field.required?,
      :field_i18n => field.i18n?,
      :field_multiple => field.multiple?
    }
  end

  def json_hidden_field_id(form, field)
    ActionView::Helpers::Tags::HiddenField
      .new(form.object_name, "#{field.uuid}_json", self)
      .send(:tag_id)
  end
end
