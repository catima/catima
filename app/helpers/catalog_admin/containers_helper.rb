module CatalogAdmin::ContainersHelper
  include CatalogAdmin::MapHelper

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

  def item_type_select(form, options = {}, html_options = {})
    form.collection_select(
      :item_type,
      catalog.item_types.sorted,
      :id,
      :name,
      options.reverse_merge(:include_blank => true),
      html_options
    )
  end

  def style_select(form, options = {}, html_options = {})
    form.collection_select(
      :style,
      ItemList::STYLES,
      :first,
      :first,
      options.reverse_merge(:include_blank => true),
      html_options
    )
  end

  def sort_direction_select(form, options = {}, html_options = {})
    form.collection_select(
      :sort_direction,
      [["ASC", "ASC"], ["DESC", "DESC"]],
      :first,
      :first,
      options,
      html_options
    )
  end

  def filterable_field_select(form, options = {})
    item_type = ItemType.find(form.object.item_type)
    form.select(
      :filterable_field_id,
      (form.object.item_type.present? && form.object.style == 'timeline') ? item_type.fields.reject{|f| f == item_type.primary_field}.map { |f| [f.name, f.id] } : [],
      {include_blank: true},
      options
    )
  end

  def field_format_select(form, options = {})
    form.select(
      :field_format,
      Field::DateTime::FORMATS.map{ |f| [f.to_s, f.to_s] },
      {include_blank: true},
      options
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
        :action => "update",
        :container => {:row_order_position => direction}
      ),
      :method => :patch,
      :remote => true
    )
  end
end
