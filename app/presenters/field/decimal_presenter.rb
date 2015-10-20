class Field::DecimalPresenter < FieldPresenter
  def input(form, method, options={})
    form.number_field(method, input_defaults(options))
  end

  # TODO
  # def value
  # end
end
