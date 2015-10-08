module Admin::CatalogsHelper
  def catalog_status_label(catalog)
    text, klass = catalog.active? ? %w(Active success) : %w(Inactive default)
    content_tag(:span, text, :class => "label label-#{klass}")
  end

  def catalog_activation_toggle(catalog, options={})
    label, at = catalog.active? ? %w(Deactivate now) : ["Reactivate", ""]
    path = admin_catalog_path(catalog, :catalog => { :deactivated_at => at })
    link_to(label, path, options.reverse_merge(:method => :patch))
  end
end
