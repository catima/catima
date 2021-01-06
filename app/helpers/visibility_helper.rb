module VisibilityHelper
  def visibility_status_label(catalog)
    return nil unless catalog.active?

    case catalog_access(catalog)
    when 2
      text = 'Members'
      klass = 'warning'
    when 3
      text = 'Catalog staff'
      klass = 'danger'
    else
      text = 'Everyone'
      klass = 'success'
    end

    tag.span(text, :class => "badge badge-#{klass}")
  end
end
