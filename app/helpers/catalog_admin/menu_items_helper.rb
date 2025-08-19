module CatalogAdmin::MenuItemsHelper
  def setup_catalog_menu_items_nav_link
    active = (params[:controller] == "catalog_admin/menu_items")
    klass = "list-group-item  list-group-item-action".dup
    klass << " active" if active

    link_to(t('menu_items'), catalog_admin_menu_items_path, :class => klass)
  end
end
