module CatalogAdmin::PagesHelper
  def setup_catalog_pages_nav_link
    active = (params[:controller] == "catalog_admin/pages")
    klass = "list-group-item  list-group-item-action"
    klass << " active" if active

    link_to(t("pages"), catalog_admin_pages_path, :class => klass)
  end

  def page_path(page)
    ["", page.catalog.slug, I18n.locale, page.slug].join("/")
  end
end
