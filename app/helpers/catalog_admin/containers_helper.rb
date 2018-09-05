module CatalogAdmin::ContainersHelper
  def render_catalog_admin_container_inputs(form)
    model_name = form.object.partial_name
    partial = "catalog_admin/containers/#{model_name}_inputs"
    render(partial, :f => form)
  end

  def container_move_up_link(container)
    container_move_link(container, "up")
  end

  def container_move_down_link(container)
    container_move_link(container, "down")
  end

  def item_type_select(form, options={})
    form.collection_select(
      :item_type,
      catalog.item_types.sorted,
      :id,
      :name,
      options.reverse_merge(:include_blank => true)
    )
  end

  private

  def container_move_link(container, direction)
    link_to(
      fa_icon(:"caret-#{direction}"),
      catalog_admin_container_path(
        @catalog,
        I18n.locale,
        container,
        {
          :action => "update",
          :container => { :row_order_position => direction }
        }
      ),
      :method => :patch,
      :remote => true
    )
  end
end
