module JsonHelper
  def json_react_display_component(item, field, props={})
    props = json_display_props(item, field).merge(props)
    react_component("#{field.display_component}/components/#{field.display_component}", props)
  end

  def json_react_input_component(form, field, props={}, options={})
    # Add the field id & options to the component props
    props = props.merge(
      :input => "##{json_hidden_field_id(form, field)}",
      :options => options
    )

    # Compute the component policies from the model props if available for the field
    if props[:componentPolicies].present?
      props[:componentPolicies] = props[:componentPolicies].transform_values do |role|
        options[:current_user].catalog_role_at_least?(options[:catalog], role)
      end
    end

    html = [
      json_hidden_field(form, field),
      react_component("#{field.editor_component}/components/#{field.editor_component}", props)
    ]
    safe_join(html)
  end

  def json_hidden_field(form, field, options={})
    method = "#{field.uuid}_json"
    id = json_hidden_field_id(form, field)
    data = options.fetch(:data, {}).merge(json_input_data(field))
    if field.belongs_to_category?
      data = data.reverse_merge(
        "field-category" => field.category_id,
        "field-category-choice-id" => field.category_choice_id,
        "field-category-choice-set-id" => field.category_choice_set_id
      )
    end
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
