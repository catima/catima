module CatalogAdmin::FieldsHelper
  def field_style_select(form)
    form.collection_select(
      :style,
      form.object.style_choices.keys,
      :itself,
      ->(key) { form.object.style_choices[key] },
      :hide_label => true
    )
  end

  def render_catalog_admin_fields_option_inputs(form)
    model_name = form.object.partial_name
    partial = "catalog_admin/fields/#{model_name}_option_inputs"
    render(partial, :f => form)
  end

  def render_catalog_admin_fields_modals(field)
    model_name = field.partial_name
    partial = "catalog_admin/fields/#{model_name}_modals"
    begin
      render(partial, :field => field)
    rescue ActionView::MissingTemplate => e
      nil
    end
  end

  def field_primary_badge(field)
    return unless field.primary?
    content_tag(:span, t("primary"), :class => "label label-warning")
  end

  def field_i18n_badge(field)
    return unless field.i18n?
    content_tag(:span, t("i18n"), :class => "label label-info")
  end

  def field_move_up_link(field)
    field_move_link(field, "up")
  end

  def field_move_down_link(field)
    field_move_link(field, "down")
  end

  def field_input(form, field, options={})
    field_presenter(form.object, field, options)
      .input(form, field.uuid, options)
  end

  def field_default_value_input(form)
    field_presenter(nil, form.object).input(
      form,
      :default_value,
      :label => t('default_value_optional'),
      :i18n => false
    )
  end

  def field_i18n_check_box(form)
    return unless catalog.valid_locales.many?

    form.form_group(
      :i18n,
      :help => t('i18n_help', languages: catalog.valid_locales.to_sentence)
    ) do
      form.check_box(:i18n, :label => t('i18n_enable'))
    end
  end

  private

  def field_move_link(field, direction)
    link_to(
      fa_icon(:"caret-#{direction}"),
      {
        :action => "update",
        :slug => field,
        :field => { :row_order_position => direction }
      },
      :method => :patch,
      :remote => true
    )
  end
end
