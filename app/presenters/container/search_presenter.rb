class Container::SearchPresenter < ContainerPresenter
  def html
    search = saved_search
    partial_name = search.is_a?(SimpleSearch) ? "simple_searches/list" : "advanced_searches/list"

    @view.params[:style] = container.content["style"] if container.content["style"].present?
    @view.render(
      "containers/search",
      :container => container,
      :partial_name => partial_name,
      :results => item_list(search),
      :saved_search => search
    )
  end

  def saved_search
    search_uuid = container.content['search']
    SimpleSearch.find_by(:uuid => search_uuid).presence || AdvancedSearch.find_by(:uuid => search_uuid)
  end

  def item_list(search)
    search_uuid = container.content['search']
    if search.is_a?(SimpleSearch)
      ::ItemList::SimpleSearchResult.new(
        :catalog => search.catalog,
        :query => search.query,
        :item_type_slug => options[:type],
        :search_uuid => search_uuid,
        :page => @view.params[:page]
      )
    else
      ::ItemList::AdvancedSearchResult.new(
        :model => search,
        :page => @view.params[:page]
      )
    end
  end
end
