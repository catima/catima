class Field::DateTimePresenter < FieldPresenter
  delegate :l, :to => :view

  def value
    dt = field.value_as_datetime(item)
    dt && l(dt, format: field.format.to_sym)
  end

  def input(form, method, _options={})
    form.viim_datetime_select(
      "#{method}_time",
      input_defaults(options).merge(:format => field.format)
    )
  end
end
