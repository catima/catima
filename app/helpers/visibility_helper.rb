module VisibilityHelper
  def visibility_status_label(catalog)
    return nil unless catalog.active?

    case catalog_access(catalog)
    when 1
      text = 'Everyone'
      klass = 'success'
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

    content_tag(:span, text, :class => "label label-#{klass}")
  end
end
