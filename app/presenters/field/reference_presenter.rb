class Field::ReferencePresenter < FieldPresenter
  delegate :related_item_type, :to => :field
  delegate :item_path, :link_to, :item_display_name, :to => :view

  def input(form, method, options={})
    form.collection_select(
      method,
      related_item_type.sorted_items,
      :id,
      method(:item_display_name),
      input_defaults(options).reverse_merge(:include_blank => true)
    )
  end

  def value
    ref = related_item_type.items.where(:id => raw_value).first
    return if ref.nil?
    link_to(
      item_display_name(ref),
      item_path(
        :catalog_slug => ref.catalog,
        :item_type_slug => ref.item_type,
        :locale => I18n.locale,
        :id => ref
      ))
  end
end
