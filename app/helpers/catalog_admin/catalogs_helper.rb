module CatalogAdmin::CatalogsHelper
  def setup_catalog_settings_nav_link
    active = (params[:controller] == "catalog_admin/catalogs" && params[:action] == "edit")
    klass = "list-group-item"
    klass << " active" if active
    link_to(I18n.t('general'), catalog_admin_settings_path, :class => klass)
  end

  def setup_catalog_style_nav_link
    active = (params[:controller] == "catalog_admin/catalogs" && params[:action] == "edit_style")
    klass = "list-group-item"
    klass << " active" if active
    link_to(I18n.t('style'), catalog_admin_style_path, :class => klass)
  end

  def catalog_access(catalog)
    return 1 if catalog.visible && !catalog.restricted
    return 2 if catalog.visible && catalog.restricted

    3
  end
end
