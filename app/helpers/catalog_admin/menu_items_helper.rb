module CatalogAdmin::MenuItemsHelper
  def setup_catalog_menu_tiems_nav_link
    active = (params[:controller] == "catalog_admin/menu_items")
    klass = "list-group-item  list-group-item-action"
    klass << " active" if active

    link_to(t('menu_items'), catalog_admin_menu_items_path, :class => klass)
  end

  # def menu_item_path(page)
  #   ["", menu_item.catalog.slug, menu_item.locale, menu_item.id].join("/")
  # end
end
