class Field::IntPresenter < FieldPresenter
  include ActionView::Helpers::NumberHelper

  def input(form, method, options={})
    form.number_field(method, input_defaults(options))
  end

  def value
    number_with_delimiter(raw_value)
  end
end
