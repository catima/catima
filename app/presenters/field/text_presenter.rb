class Field::TextPresenter < FieldPresenter
  delegate :locale_form_group, :truncate, :to => :view

  def value
    compact? ? truncate(super.to_s, :length => 100) : super
  end

  def input(form, method, options={})
    i18n = options.fetch(:i18n) { field.i18n? }
    return i18n_input(form, method, options) if i18n
    form.text_area(method, input_defaults(options).merge(:rows => 1))
  end

  def i18n_input(form, method, options={})
    locale_form_group(form, method, :text_field, input_defaults(options))
  end
end
