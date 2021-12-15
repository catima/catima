class Field::DateTimePresenter < FieldPresenter
  delegate :l, :to => :view

  # Returns the date time value as text for presentation.
  # As we support any date of any range, we format the date first with a fixed year (8888),
  # and replace the year after with the true one.
  def value(format: false)
    dt = raw_value
    return nil if dt.nil? || dt.values.all?(&:blank?)

    dt["raw_value"].nil? ? new_style_value_text_repr(dt, format) : old_style_value_text_repr(dt, format)
  end

  # Text representation for old style values, such as {:raw_value => 45034034}
  def old_style_value_text_repr(dt, format)
    format = format ? format : field.format
    dt_value = Time.zone.at(dt["raw_value"])
    return dt_value if view.nil?

    I18n.l(dt_value, format: format.to_sym)
  end

  def new_style_value_text_repr(dt, format)
    format = format ? format : field.format
    format_str = format.chars.reject { |v| dt[v].blank? }.join
    validate_datetime_format_string(format_str)
    return nil if format_str.empty?

    begin
      dt_value = DateTime.civil_from_format(:local, *prepare_datetime_array)
      text_repr = I18n.l(dt_value, format: format_str.to_sym)
      text_repr.sub('8888', dt[0].to_s) if dt["raw_value"].nil?
    rescue StandardError
      nil
    end
  end

  def input(form, method, options={})
    form.text_field(method, input_defaults(options))
  end

  private

  def prepare_datetime_array
    dt = field.value_as_array(item)
    dt.enum_for(:each_with_index).map do |v, i|
      if v.present?
        v
      else
        i == 0 ? 8888 : 1
      end
    end
  end

  def validate_datetime_format_string(dtstr)
    s = dtstr
    loop do
      break if Field::DateTime::FORMATS.include?(s) || s.empty?

      s = s[0...-1]
    end
    s
  end
end
