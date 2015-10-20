class Field::URLPresenter < FieldPresenter
  def input(form, method, options={})
    form.url_field(method, input_defaults(options).reverse_merge(:help => help))
  end
end
