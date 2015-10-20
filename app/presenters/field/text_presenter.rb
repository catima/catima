class Field::TextPresenter < FieldPresenter
  def input(form, method, options={})
    form.text_field(method, input_defaults(options))
  end
end
