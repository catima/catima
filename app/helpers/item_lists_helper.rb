module ItemListsHelper
  def item_list_link(list, item, offset, label=nil, &block)
    item_list_presenter(list, item, offset).item_link(label, &block)
  end

  def item_list_has_images?(list)
    first = list.items.to_a.first
    first.try(:image?)
  end

  def render_item_list(list, params=nil, container=nil)
    partial = item_list_has_images?(list) ? ItemList::STYLES["thumb"] : ItemList::STYLES["list"]
    partial = ItemList::STYLES["list"] if favorites_scoped?
    partial = ItemList::STYLES[params[:style]] if style_param?(params)
    render(partial, :item_list => list, container: container)
  end

  def render_item_list_nav(list, item)
    item_list_presenter(list, item, params[:offset]).render_nav
  end

  def item_list_title(item, item_type)
    return item_type.name_plural + " (#{item.default_display_name})" if item.present?

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

  def define_sort_direction(sort)
    # Define direction
    direction = Container::Sort.direction(sort) || sort

    # Check if direction is valid (ASC|DESC), otherwise default to ASC
    return ItemList::Sort.ascending unless ItemList::Sort.included?(direction)

    direction
  end

  def item_list_is_valid?(container)
    return false unless container.is_a?(Container::ItemList)

    return true if container.style.eql?("line")

    return true if container.sort.empty?

    return true unless Container::Sort.field_choices.key?(container.sort)

    it = ItemType.find(container.item_type)
    return true if it&.field_for_select&.sortable?

    false
  end
end
