module ItemsHelper
  def search_item_link(item, offset, label=nil, &block)
    link_to(
      block ? capture(&block) : label,
      item_path(
        :item_type_slug => item.item_type,
        :id => item,
        :offset => offset,
        :q => params[:q]
      ))
  end

  # TODO: handle advanced search
  def render_items_search_nav(search, item)
    nav = search_navigation(search, item)
    return if nav.nil?

    render(
      :partial => "items/search_nav",
      :locals => {
        :nav => nav,
        :search => search,
        :search_path => simple_search_path(
          :q => search.query,
          :page => search.page_for_offset(nav.offset_actual),
          :type => item.item_type.slug
        )
      }
    )
  end

  private

  def search_navigation(search, item)
    return nil if params[:offset].blank?

    Search::Navigation.new(
      :results => search.items.where(:item_type_id => item.item_type_id),
      :offset => params[:offset].to_i,
      :current => item
    )
  end
end
