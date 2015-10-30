class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :to => :field

  def input(form, method, options={})
    form.collection_select(
      method,
      choices,
      :id,
      :short_name,
      input_defaults(options).reverse_merge(:include_blank => true)
    )
  end

  def value(_style)
    choices.except(:order).where(:id => raw_value).first.try(:long_name)
  end
end
