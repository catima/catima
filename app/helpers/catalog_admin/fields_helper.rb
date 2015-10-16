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

  def field_primary_badge(field)
    return unless field.primary?
    content_tag(:span, "Primary", :class => "label label-warning")
  end

  def field_move_up_link(field)
    field_move_link(field, "up", :if_not => :first)
  end

  def field_move_down_link(field)
    field_move_link(field, "down", :if_not => :last)
  end

  private

  def field_move_link(field, direction, if_not:)
    return if field.item_type.fields.sorted.public_send(if_not) == field
    link_to(
      fa_icon(:"caret-#{direction}"),
      {
        :action => "update",
        :slug => field,
        :field => { :row_order_position => direction }
      },
      :method => :patch
    )
  end
end
