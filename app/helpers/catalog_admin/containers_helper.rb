module CatalogAdmin::ContainersHelper
  def render_catalog_admin_container_inputs(form)
    model_name = form.object.partial_name
    partial = "catalog_admin/containers/#{model_name}_inputs"
    render(partial, :f => form)
  end
end