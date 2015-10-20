class Field::ReferencePresenter < FieldPresenter
  delegate :related_item_type, :to => :field

  def input(form, method)
    form.collection_select(
      method,
      related_item_type.sorted_items,
      :id,
      :display_name, # TODO: use primary field
      :label => label
    )
  end

  def value
    related_item_type.items.where(:id => raw_value).first.try(:display_name)
  end
end
