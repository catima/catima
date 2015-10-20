class Field::EmailPresenter < FieldPresenter
  def input(form, method)
    form.email_field(method, :label => label)
  end
end
