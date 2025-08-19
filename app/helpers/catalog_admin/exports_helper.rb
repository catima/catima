module CatalogAdmin::ExportsHelper
  def setup_catalog_exports_nav_link
    active = (params[:controller] == "catalog_admin/exports")
    klass = "list-group-item  list-group-item-action".dup
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
    tag.span(export.status, class: "badge text-bg-#{type}")
  end

  def validity_badge(export)
    badge = export.validity? ? { :label => t("valid"), :type => "success" } : { :label => t("expired"), :type => "danger" }
    tag.span(badge[:label], class: "badge text-bg-#{badge[:type]}")
  end

  def with_files_check(export)
    tag.i(nil, class: "fa fa-check") if export.with_files
  end
end
