class Field::TextPresenter < FieldPresenter
  delegate :locale_form_group, :to => :view

  def input(form, method, options={})
    i18n = options.fetch(:i18n) { field.i18n? }
    return i18n_input(form, method, options) if i18n
    form.text_field(method, input_defaults(options))
  end

  def i18n_input(form, method, options={})
    locale_form_group(form, method, :text_field, input_defaults(options))
  end
end
