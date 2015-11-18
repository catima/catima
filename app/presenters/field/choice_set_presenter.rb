class Field::ChoiceSetPresenter < FieldPresenter
  delegate :choices, :selected_choice, :to => :field
  delegate :link_to, :items_path, :to => :view

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
    choice = selected_choice(item)
    return if choice.nil?

    link_to(
      choice.long_name,
      items_path(
        :catalog_slug => item.catalog,
        :item_type_slug => item.item_type,
        :locale => I18n.locale,
        field.slug => [I18n.locale, choice.short_name].join("-")
      ))
  end
end
