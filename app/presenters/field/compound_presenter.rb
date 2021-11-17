class Field::CompoundPresenter < FieldPresenter
  def input(form, method, options = {})
    form.text_field(method, input_defaults(options).reverse_merge(:help => help, :value => field.template, :readonly => true))
  end

  def value
    render_template
  end

  def render_template
    tpl = JSON.parse(field.template)

    local_template = tpl[I18n.locale.to_s] || ''
    displayable_fields = @item.fields.where(slug: local_template.gsub('&nbsp', ' ').to_enum(:scan, /(\{\{.*?\}\})/i).map { |m, _| m.gsub('{', '').gsub('}', '') })
    displayable_fields = displayable_fields.select { |fld| fld.displayable_to_user?(@current_user) } if @current_user
    displayable_fields.each do |field|
      presenter = "#{field.class.name}Presenter".constantize.new(@view, @item, field, {}, @current_user)

      local_template = local_template.gsub("{{#{field.slug}}}", presenter.value || '')
    end
    local_template = local_template.gsub(/(\{\{.*?\}\})/i, '')
    (@options[:strip_p] == true ? strip_p(local_template) : local_template).html_safe
  end

  def strip_p(html)
    white_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    white_list_sanitizer.sanitize(html, tags: %w(b strong i emph u strike sup sub a))
  end
end
