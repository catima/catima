class Field::CompoundPresenter < FieldPresenter
  delegate :locale_form_group, :strip_tags, :to => :view

  def input(form, method, options={})
    i18n = field.item_type.catalog.valid_locales.many?
    raw_input(form, method, options, i18n)
  end

  def raw_input(form, method, options={}, i18n=false)
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

  def value(locale: I18n.locale)
    render_template(locale)
  end

  def render_template(locale)
    # Parse the template JSON and get the template for the specified locale
    local_template = JSON.parse(field.template).fetch(locale.to_s, '')

    # Select displayable fields based on conditions and user permissions
    displayable_fields = field.item_type.fields.select do |fld|
      fld.human_readable? && (fld.displayable_to_user?(@user) if @user)
    end

    # Replace template placeholders with field values using presenters
    displayable_fields.each do |field|
      presenter = "#{field.class.name}Presenter".constantize.new(@view, @item, field, { :style => :compact }, @user)
      local_template = local_template.gsub("{{#{field.slug}}}", presenter.value || '')
    end

    # Remove remaining placeholders and HTML tags, then make the result HTML safe
    strip_p(local_template.gsub(/(\{\{.*?\}\})/i, '')).html_safe
  end

  def strip_p(html)
    allow_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    allow_list_sanitizer.sanitize(html, tags: %w(b strong i emph u strike sup sub))
  end
end
