class Field::CompoundPresenter < FieldPresenter
  def input(form, method, options = {})
    form.text_field(method, input_defaults(options).reverse_merge(:help => help, :value => field.template, :readonly => true))
  end

  def value
    render_template
  end

  def render_template
    tpl = JSON.parse(field.template)

    local_tpl = tpl[I18n.locale.to_s] || ''
    displayable_fields = @item.fields.where(slug: local_tpl.gsub('&nbsp', ' ').to_enum(:scan, /(\{\{.*?\}\})/i).map { |m,| m.gsub('{', '').gsub('}', '') })
    displayable_fields = displayable_fields.select { |fld| fld.displayable_to_user?(@current_user) } if @current_user
    displayable_fields.each do |field|
      presenter = "#{field.class.name}Presenter".constantize.new(@view, @item, field, {}, @current_user)

      local_tpl = local_tpl.gsub('{{' + field.slug + '}}', presenter.value || '')
    end
    local_tpl = local_tpl.gsub(/(\{\{.*?\}\})/i, '')
    (@options[:strip_p] == true ? strip_p(local_tpl) : local_tpl).html_safe
  end

  def strip_p(html)
    white_list_sanitizer = Rails::Html::WhiteListSanitizer.new
    white_list_sanitizer.sanitize(html, tags: %w(b strong i emph u strike sup sub a))
  end
end
