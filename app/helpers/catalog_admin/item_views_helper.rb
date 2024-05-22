module CatalogAdmin::ItemViewsHelper
  def list_view_badge(item_view)
    return unless item_view.default_for_list_view

    tag.span(I18n.t('item_list'), :class => "badge text-bg-success")
  end

  def item_view_badge(item_view)
    return unless item_view.default_for_item_view

    tag.span(I18n.t('item_view'), :class => "badge text-bg-warning")
  end

  def display_name_badge(item_view)
    return unless item_view.default_for_display_name

    tag.span(I18n.t('item_display_name'), class: "badge text-bg-primary")
  end
end
