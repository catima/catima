module ItemListsHelper
  def item_list_link(list, item, offset, label=nil, &block)
    item_list_presenter(list, item, offset).item_link(label, &block)
  end

  def item_list_has_images?(list)
    first = list.items.to_a.first
    first.try(:image?)
  end

  def render_item_list(list, params=nil, container: nil)
    partial = item_list_has_images?(list) ? ItemList::STYLES["thumb"] : ItemList::STYLES["list"]
    partial = ItemList::STYLES["list"] if favorites_scoped?
    partial = ItemList::STYLES[params[:style]] if style_param?(params)
    render(partial, :item_list => list, container: container)
  end

  def render_item_list_nav(list, item)
    item_list_presenter(list, item, params[:offset]).render_nav
  end

  def item_list_title(item, item_type)
    return item_type.name_plural + " (" + item.default_display_name + ")" if item.present?

    item_type.name_plural
  end

  private

  def item_list_presenter(list, item, offset)
    klass = "#{list.class.name}Presenter".constantize
    klass.new(self, item, offset, list)
  end

  def style_param?(params)
    return false if params.blank?
    return false if params[:style].blank?
    return false unless ItemList::STYLES.include?(params[:style])

    true
  end
end
