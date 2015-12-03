class Field::XrefPresenter < FieldPresenter
  delegate :choices, :selected_choice, :to => :field
  delegate :browse_similar_items_link, :to => :view

  def input(form, method, options={})
    form.collection_select(
      method,
      choices,
      :id,
      :name,
      input_defaults(options).reverse_merge(:include_blank => true)
    )
  end

  def value
    choice = selected_choice(item)
    return if choice.nil?
    value_slug = [I18n.locale, choice.name].join("-")
    browse_similar_items_link(choice.long_name, item, field, value_slug)
  end
end
