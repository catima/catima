class Field::EmbedPresenter < FieldPresenter
  COMPACT_WIDTH = 300
  COMPACT_HEIGHT = 150

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
      compact? ? raw_value&.gsub(/width=["']\d+["']/, "width=\"#{COMPACT_WIDTH}\"")&.gsub(/height=["']\d+["']/, "height=\"#{COMPACT_HEIGHT}\"")&.html_safe : raw_value&.html_safe
    elsif field.url? && raw_value
      "<iframe width='#{compact? ? COMPACT_WIDTH : field.iframe_width}' height='#{compact? ? COMPACT_HEIGHT : field.iframe_height}' style='border: none;' src='#{raw_value}'></iframe>".html_safe
    end
  end

  def value?
    value.present?
  end
end
