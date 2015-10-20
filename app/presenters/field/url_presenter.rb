class Field::URLPresenter < FieldPresenter
  def input(form, method)
    form.url_field(method, :label => label, :help => help)
  end
end
