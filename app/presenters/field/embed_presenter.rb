class Field::EmbedPresenter < FieldPresenter

  def input(form, method, options = {})
    if field.code?
      form.text_area(method, input_defaults(options))
    elsif field.url?
      form.url_field(method, input_defaults(options).reverse_merge(help: help))
    end
  end

  def value
    if field.code?
      raw_value&.html_safe
      compact? ? raw_value.gsub(/width=["']\d+["']/, 'width="300"').gsub(/height=["']\d+["']/, 'height="300"')&.html_safe : raw_value&.html_safe
    elsif field.url? && raw_value
      "<iframe width='#{compact? ? 300 : field.options['width']}' height='#{compact? ? 300 : field.options['height']}' style='border: none;' src='#{raw_value}'></iframe>".html_safe
    end
  end

  def value?
    value.present?
  end
end
