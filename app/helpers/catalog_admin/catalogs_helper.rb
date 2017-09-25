module CatalogAdmin::CatalogsHelper
  def setup_catalog_settings_nav_link
    active = (params[:controller] == "catalog_admin/catalogs")
    klass = "list-group-item"
    klass << " active" if active
    link_to(t("catalog_admin.catalog.settings"), catalog_admin_settings_path, :class => klass)
  end
end
