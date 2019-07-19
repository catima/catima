class ItemList::SimpleSearchAdminResult < ItemList::SimpleSearchResult
  def unpaginaged_items
    scope = active_item_type ? active_item_type.items : Item.none
    scope.merge(relation).unscope(:order)
  end
end
