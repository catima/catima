class Container::ItemListPresenter < ContainerPresenter

  include ItemListsHelper

  def html
    catalog = Catalog.find_by(slug: @view.params[:catalog_slug])
    @item_type = catalog.item_types.where(:id => @container.item_type).first!
    @list = ::ItemList::Filter.new(
      :item_type => @item_type,
      :page => @view.params[:page]
    )
    partial = item_list_has_images?(@list) ? "items/thumbnails" : "items/list"
    @view.render(partial, :item_list => @list)
  end
end