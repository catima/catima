class Field::IntPresenter < FieldPresenter
  delegate :number_with_delimiter, :to => :view

  def input(form, method)
    form.number_field(method, :label => label)
  end

  def value
    number_with_delimiter(raw_value)
  end
end
