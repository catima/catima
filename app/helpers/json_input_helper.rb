module JsonInputHelper
  def json_react_component(component_name, form, field, props={})
    props = props.merge(:input => "##{json_hidden_field_id(form, field)}")
    html = [
      json_hidden_field(form, field),
      react_component(component_name, props)
    ]
    safe_join(html)
  end

  def json_hidden_field(form, field, options={})
    method = "#{field.uuid}_json"
    id = json_hidden_field_id(form, field)
    data = options.fetch(:data, {}).merge(json_field_data(field))
    form.hidden_field(method, options.merge(:data => data, :id => id))
  end

  def json_field_data(field)
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
