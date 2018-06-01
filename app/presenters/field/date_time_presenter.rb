class Field::DateTimePresenter < FieldPresenter
  delegate :l, :to => :view

  # Returns the date time value as text for presentation.
  # As we support any date of any range, we format the date first with a fixed year (8888),
  # and replace the year after with the true one.
  def value
    dt = raw_value
    return nil if dt.nil? || dt.values.all?(&:blank?)
    format_str = dt["raw_value"].nil? ? field.format.split('').reject { |v| dt[v].blank? }.join : field.format
    validate_datetime_format_string(format_str)
    return nil if format_str.empty?
    unless dt["raw_value"].nil?
      dt_value = Time.at(dt["raw_value"])
      text_repr = l(dt_value, format: format_str.to_sym)
    else
      dt_value = DateTime.civil_from_format(:local, *prepare_datetime_array)
      text_repr = l(dt_value, format: format_str.to_sym)
      text_repr.sub('8888', dt[0].to_s) if dt["raw_value"].nil?
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
      break if Field::DateTime::FORMATS.include?(s) || s.length == 0
      s = s[0...-1]
    end
    s
  end
end
