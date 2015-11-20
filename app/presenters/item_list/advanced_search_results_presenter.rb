class ItemList::AdvancedSearchResultsPresenter < ItemListPresenter
  delegate :advanced_search_path, :to => :view

  private

  def path
    advanced_search_path(
      :uuid => list.model.uuid,
      :page => list.page_for_offset(nav.offset_actual)
    )
  end

  def context_param
    :search
  end
end
