module CatalogAdmin::FieldsHelper
  include CatalogAdmin::MapHelper

  def field_style_select(form)
    form.collection_select(
      :style,
      form.object.style_choices.keys,
      :itself,
      ->(key) { I18n.t(".catalog_admin.fields.common_form_fields.#{translation_choice_name(key)}_choice") },
      {
        :hide_label => true
      }
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

    tag.span(t("primary"), :class => "badge text-bg-warning")
  end

  def field_restricted_badge(field)
    return unless field.restricted?

    tag.span(fa_icon(:lock), class: 'badge text-bg-danger')
  end

  def field_i18n_badge(field)
    return unless field.i18n?

    tag.span(t("i18n"), :class => "badge text-bg-info")
  end

  def field_formatted_badge(field)
    return unless field.respond_to?(:formatted?) && field.formatted?

    tag.span(t("formatted"), :class => "badge text-bg-info")
  end

  def field_move_up_link(field)
    field_move_link(field, "up")
  end

  def field_move_down_link(field)
    field_move_link(field, "down")
  end

  def field_input(form, field, options={})
    if field.editor_component.present?
      return field_json_input(
        form,
        field,
        field.edit_props(item: @item),
        options
      )
    end

    options[:wrapper] = { class: 'mb-3 form-group' }
    field_presenter(form.object, field, options)
      .input(form, field.uuid, options)
  end

  def field_json_input(form, field, props={}, options={})
    label = field_presenter(form.object, field).field_label
    form.form_group(field.uuid, :label => { :text => label }, class: "mb-3 form-group") do
      json_react_input_component(form, field, props, options)
    end
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

  def field_legend_check_box(form)
    form.form_group(
      :legend,
      :help => t('legend_help')
    ) do
      form.check_box(:legend, :label => t('legend_enable'))
    end
  end

  private

  # Clean the type name of the choice to match translation strings
  def translation_choice_name(key)
    key.sub('-', '_').downcase
  end

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
