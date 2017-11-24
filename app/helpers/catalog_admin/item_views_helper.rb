module CatalogAdmin::ItemViewsHelper
  def item_view_list_view_badge(item_view)
    return unless item_view.default_for_list_view
    content_tag(:span, "Default list view", :class => "label label-success")
  end

  def item_view_item_view_badge(item_view)
    return unless item_view.default_for_item_view
    content_tag(:span, "Default item view", :class => "label label-warning")
  end
end
