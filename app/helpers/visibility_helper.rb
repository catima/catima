module VisibilityHelper
  def visibility_status_label(catalog)
    return nil unless catalog.not_deactivated?

    case catalog_access(catalog)
    when CatalogAdmin::CatalogsHelper::CATALOG_ACCESS[:open_to_members]
      text = 'Members'
      klass = 'warning'
    when CatalogAdmin::CatalogsHelper::CATALOG_ACCESS[:open_to_catalog_staff]
      text = 'Catalog staff'
      klass = 'danger'
    else
      text = 'Everyone'
      klass = 'success'
    end

    tag.span(text, :class => "badge text-bg-#{klass}")
  end
end
