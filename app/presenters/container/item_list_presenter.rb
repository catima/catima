class Container::ItemListPresenter < ContainerPresenter
  include ItemListsHelper

  def html
    catalog = Catalog.find_by(slug: @view.params[:catalog_slug])
    begin
      @item_type = catalog.item_types.where(:id => @container.item_type).first!
      @list = ::ItemList::Filter.new(
        :item_type => @item_type,
        :page => @view.params[:page],
        sort_type: Container::Sort.type(@container&.sort),
        sort_field: @container.sort_field,
        sort: Container::Sort.direction(@container&.sort)
      )
      @view.params[:style] = container.content["style"] if container.content["style"].present?
      @view.render("containers/item_list", :item_list => @list, container: @container)
    rescue ActiveRecord::RecordNotFound
      @view.render("containers/item_list", :item_list => nil)
    end
  end
end
