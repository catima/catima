class Field::BooleanPresenter < FieldPresenter
  def value
    raw_value.to_i == 1 ? t('yes') : t('no')
  end

  def input(form, method, options = {})
    category = field.belongs_to_category? ? {"field-category": field.category_id, "field-category-choice-id": field.category_choice.id, "field-category-choice-set-id": field.category_choice_set.id} : {}
    form.select(
      method,
      select_values,
      input_defaults(options).merge(:selected => raw_value, :include_blank => !@field.required),
      data: category
    )
  end

  def select_values
    {t('yes') => "1", t('no') => "0"}
  end
end
