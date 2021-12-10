class Field::CompoundPresenter < FieldPresenter
  delegate :locale_form_group, :strip_tags, :to => :view

  def input(form, method, options={})
    i18n = field.item_type.catalog.valid_locales.many?
    raw_input(form, method, options, i18n)
  end

  def raw_input(form, method, options={}, i18n: false)
    return i18n_input(form, method, options) if i18n

    form.text_field(
      method,
      input_defaults(options).reverse_merge(
        value: strip_tags(JSON.parse(field.template)[field.item_type.catalog.valid_locales.first]),
        readonly: true
      )
    )
  end

  def i18n_input(form, method, options={})
    locale_form_group(
      form,
      method,
      :text_field,
      input_defaults(
        options.reverse_merge(value: field.template, readonly: true, is_compound: true)
      )
    )
  end

  def value
    render_template
  end

  def render_template
    tpl = JSON.parse(field.template)

    local_template = tpl[I18n.locale.to_s] || ''

    displayable_fields = @item.fields.where(slug: local_template.gsub('&nbsp', ' ').to_enum(:scan, /(\{\{.*?\}\})/i).map { |m, _| m.gsub('{', '').gsub('}', '') })
    displayable_fields = displayable_fields.select { |fld| fld.displayable_to_user?(@user) } if @user
    displayable_fields.each do |field|
      presenter = "#{field.class.name}Presenter".constantize.new(@view, @item, field, { :style => :compact }, @user)
      local_template = local_template.gsub("{{#{field.slug}}}", presenter.value || '')
    end

    strip_p(local_template.gsub(/(\{\{.*?\}\})/i, '')).html_safe
  end

  def strip_p(html)
    allow_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    allow_list_sanitizer.sanitize(html, tags: %w(b strong i emph u strike sup sub))
  end
end
