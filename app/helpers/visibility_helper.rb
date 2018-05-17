module VisibilityHelper
  def visibility_status_label(catalog)
    return nil unless catalog.active?
    text, klass = catalog.visible? ? %w(Visible success) : %w(Not\ visible default)
    content_tag(:span, text, :class => "label label-#{klass}")
  end
end
