class Field::DateTimePresenter < FieldPresenter
  delegate :l, :to => :view

  # Returns the date time value as text for presentation.
  def value
    dt = field.value_as_array(item)
    return nil if dt.nil?
    format_str = field.format.split('').reject { |v| dt[v.to_i].nil? }.join
    validate_datetime_format_string(format_str)
    arr_repr = dt.reject(&:blank?)
    l(DateTime.civil_from_format(:local, *arr_repr), format: format_str.to_sym)
  end

  def input(form, method, options={})
    form.text_field(method, input_defaults(options))
  end

  private

  def validate_datetime_format_string(dtstr)
    s = dtstr
    loop do
      break if Field::DateTime::FORMATS.include?(s) || s.length.empty?
      s = s[0...-1]
    end
    s
  end
end
