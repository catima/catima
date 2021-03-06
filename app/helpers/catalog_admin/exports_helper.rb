module CatalogAdmin::ExportsHelper
  def setup_catalog_exports_nav_link
    active = (params[:controller] == "catalog_admin/exports")
    klass = "list-group-item  list-group-item-action"
    klass << " active" if active
    link_to(t("export").pluralize, catalog_admin_exports_path, :class => klass)
  end

  def status_badge(export)
    type = case export.status
           when "error" then "danger"
           when "processing" then "warning"
           when "ready" then "success"
           else "default"
           end
    tag.span(export.status, class: "badge badge-#{type}")
  end

  def validity_badge(export)
    badge = export.validity? ? { :label => t("valid"), :type => "success" } : { :label => t("expired"), :type => "danger" }
    tag.span(badge[:label], class: "badge badge-#{badge[:type]}")
  end

  def available_categories
    # Only system admins can create sql & csv exports
    return Export::CATEGORY_OPTIONS if current_user.system_admin?

    # Catalog admins are restricted to the catima format
    Export::CATEGORY_OPTIONS.select { |cat| cat.eql? "catima" }
  end
end
