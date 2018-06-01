module ItemListsHelper
  def item_list_link(list, item, offset, label=nil, &block)
    item_list_presenter(list, item, offset).item_link(label, &block)
  end

  def item_list_has_images?(list)
    first = list.items.to_a.first
    first.try(:image?)
  end

  def render_item_list(list)
    partial = item_list_has_images?(list) ? "items/thumbnails" : "items/list"
    partial = "items/list" if favorites_scoped?
    render(partial, :item_list => list)
  end

  def render_item_list_nav(list, item)
    item_list_presenter(list, item, params[:offset]).render_nav
  end

  private

  def item_list_presenter(list, item, offset)
    klass = "#{list.class.name}Presenter".constantize
    klass.new(self, item, offset, list)
  end
end
