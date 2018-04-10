class Field::BooleanPresenter < FieldPresenter
  def value
    raw_value.to_i == 1 ? t('yes') : t('no')
  end

  def input(form, method, options={})
    form.select(
      method,
      select_values,
      input_defaults(options).merge(:selected => raw_value, :include_blank => !@field.required)
    )
  end

  def select_values
    { t('yes') => "1", t('no') => "0" }
  end
end
