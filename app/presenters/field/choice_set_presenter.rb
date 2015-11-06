class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :selected_choice, :to => :field

  def input(form, method, options={})
    form.collection_select(
      method,
      choices,
      :id,
      :short_name,
      input_defaults(options).reverse_merge(:include_blank => true)
    )
  end

  def value
    selected_choice(item).try(:long_name)
  end
end
