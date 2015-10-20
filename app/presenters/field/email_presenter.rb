class Field::EmailPresenter < FieldPresenter
  def input(form, method, options={})
    form.email_field(
      method,
      input_defaults(options).merge(:autocomplete => "off")
    )
  end
end
