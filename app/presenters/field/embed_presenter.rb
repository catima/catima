class Field::EmbedPresenter < FieldPresenter

  def input(form, method, options = {})
    if field.code?
      form.text_area(method, input_defaults(options))
    elsif field.url?
      form.url_field(method, input_defaults(options).reverse_merge(:help => help))
    end
  end

  def value
    if field.code?
      raw_value&.html_safe
    elsif field.url?
      raw_value ? "<iframe width='#{field.options['width']}' height='#{field.options['height']}' style='border: none;' src='#{raw_value}'></iframe>".html_safe : nil
    end
  end
end
