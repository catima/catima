module CatalogAdmin::ExportsHelper
  def setup_catalog_exports_nav_link
    active = (params[:controller] == "catalog_admin/exports")
    klass = "list-group-item"
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

    content_tag(:span, export.status, class: "label label-#{type}")
  end

  def validity_badge(export)
    icon = export.validity? ? "check" : "times"

    content_tag(:i, nil, class: "fa fa-#{icon}")
  end
end
