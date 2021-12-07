class Field::EmbedPresenter < FieldPresenter
  COMPACT_WIDTH = 300
  COMPACT_HEIGHT = 150

  def input(form, method, options={})
    if field.iframe?
      form.text_area(method, input_defaults(options))
    elsif field.url?
      form.url_field(method, input_defaults(options).reverse_merge(help: help))
    end
  end

  def value
    return nil if raw_value.blank?

    if field.iframe?
      if compact?
        return raw_value&.gsub(/style=["'].*["']/, "style=\"width:#{COMPACT_WIDTH}px; height:#{COMPACT_HEIGHT}px; border: none;\"")
                 &.gsub(/width=["']\d+["']/, "width=\"#{COMPACT_WIDTH}\"")
                 &.gsub(/height=["']\d+["']/, "height=\"#{COMPACT_HEIGHT}\"")
                 &.html_safe
      end

      raw_value&.html_safe
    elsif field.url?
      "<iframe width='#{compact? ? COMPACT_WIDTH : field.iframe_width}' height='#{compact? ? COMPACT_HEIGHT : field.iframe_height}' style='border: none;' src='#{raw_value}'></iframe>".html_safe
    end
  end

  def value?
    value.present?
  end
end
