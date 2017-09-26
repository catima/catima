class Field::DateTimePresenter < FieldPresenter
  delegate :l, :to => :view

  # Returns the date time value as text for presentation.
  # As we support any date of any range, we format the date first with a fixed year (8888),
  # and replace the year after with the true one.
  def value
    dt = field.value_as_array(item)
    return nil if dt.nil?
    arr_repr = (0..(dt.length - 1)).collect { |i| i == 0 ? 8888 : dt[i] }
    text_repr = l(DateTime.civil_from_format(:local, *arr_repr), format: field.format.to_sym)
    text_repr.sub('8888', dt[0].to_s)
  end

  def input(form, method, options={})
    form.text_field(method, input_defaults(options))
  end
end
