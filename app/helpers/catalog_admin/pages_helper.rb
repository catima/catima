module CatalogAdmin::PagesHelper
  def setup_catalog_pages_nav_link
    active = (params[:controller] == "catalog_admin/pages")
    klass = "list-group-item"
    klass << " active" if active

    link_to("Pages", catalog_admin_pages_path, :class => klass)
  end

  def page_path(page)
    ["", page.catalog.slug, page.locale, page.slug].join("/")
  end
end
