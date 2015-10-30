class Field::ReferencePresenter < FieldPresenter
  delegate :related_item_type, :to => :field

  def input(form, method, options={})
    form.collection_select(
      method,
      related_item_type.sorted_items,
      :id,
      :display_name,
      input_defaults(options).reverse_merge(:include_blank => true)
    )
  end

  def value
    related_item_type.items.where(:id => raw_value).first.try(:display_name)
  end
end
