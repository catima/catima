class ItemList::SimpleSearchResultPresenter < ItemListPresenter
  delegate :simple_search_path, :to => :view

  private

  def path
    simple_search_path(
      :q => list.query,
      :page => list.page_for_offset(nav.offset_actual),
      :type => list.item_type_slug
    )
  end

  def context_param
    :q
  end
end
