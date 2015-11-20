module ItemListsHelper
  def item_list_link(list, item, offset, label=nil, &block)
    item_list_presenter(list, item, offset).item_link(label, &block)
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
