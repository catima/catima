module CatalogAdmin::ItemViewsHelper
  def list_view_badge(item_view)
    return unless item_view.default_for_list_view
    content_tag(:span, "List view", :class => "label label-success")
  end

  def item_view_badge(item_view)
    return unless item_view.default_for_item_view
    content_tag(:span, "Item view", :class => "label label-warning")
  end

  def display_name_badge(item_view)
    return unless item_view.default_for_display_name
    content_tag(:span, 'Display name', class: 'label label-primary')
  end
end
