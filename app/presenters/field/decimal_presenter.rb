class Field::DecimalPresenter < FieldPresenter
  delegate :number_with_delimiter, :to => :view

  def input(form, method, options={})
    form.number_field(method, input_defaults(options))
  end

  def value
    number_with_delimiter(raw_value)
  end
end
