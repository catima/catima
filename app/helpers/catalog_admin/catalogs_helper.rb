module CatalogAdmin::CatalogsHelper
  def setup_catalog_settings_nav_link
    active = (params[:controller] == "catalog_admin/catalogs" && params[:action] == "edit")
    klass = "list-group-item"
    klass << " active" if active
    link_to("General", catalog_admin_settings_path, :class => klass)
  end

  def setup_catalog_style_nav_link
    active = (params[:controller] == "catalog_admin/catalogs" && params[:action] == "edit_style")
    klass = "list-group-item"
    klass << " active" if active
    link_to("Style", catalog_admin_style_path, :class => klass)
  end
end
