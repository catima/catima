class Field::DecimalPresenter < FieldPresenter
  include ActionView::Helpers::NumberHelper

  def input(form, method, options={})
    form.number_field(method, input_defaults(options).merge(:step => "any"))
  end

  def value
    number_with_delimiter(raw_value)
  end
end
