class Field::XrefPresenter < FieldPresenter
  delegate :choices, :selected_choices, :to => :field
  delegate :select2_collection_select, :browse_similar_items_link, :to => :view

  def input(form, method, options={})
    select2_collection_select(
      form,
      method,
      choices,
      :id,
      :name,
      input_defaults(options).merge(:multiple => field.multiple?)
    )
  end

  def value
    choices = selected_choices(item)
    return if choices.empty?

    choices.map do |choice|
      value_slug = [choice.id, choice.name].join("-")
      browse_similar_items_link(choice.name, item, field, value_slug)
    end.join(", ").html_safe
  end
end
