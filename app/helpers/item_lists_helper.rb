module ItemListsHelper
  def item_list_link(search, item, offset, label=nil, &block)
    item_list_presenter(search, item, offset).item_link(label, &block)
  end

  def render_item_list_nav(search, item)
    item_list_presenter(search, item, params[:offset]).render_nav
  end

  private

  def item_list_presenter(search, item, offset)
    # TODO
    # klass = "#{search.class.name}Presenter".constantize
    name = case search
           when Search::Advanced then "AdvancedSearchResults"
           when Search::References then "References"
           when Search::Browse then "Filter"
           when Search::Simple then "SimpleSearchResults"
           end
    klass = "ItemList::#{name}Presenter".constantize
    klass.new(self, item, offset, search)
  end
end
