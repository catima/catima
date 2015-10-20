class Field::TextPresenter < FieldPresenter
  def input(form, method)
    form.text_field(method, :label => label)
  end
end
