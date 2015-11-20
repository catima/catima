class ItemList::FilterPresenter < ItemListPresenter
  delegate :items_path, :to => :view

  private

  def path
    items_path(
      :item_type_slug => list.item_type,
      list.field.slug => list.value,
      :page => list.page_for_offset(nav.offset_actual)
    ) if list.field
  end

  def context_param
    :browse
  end
end
