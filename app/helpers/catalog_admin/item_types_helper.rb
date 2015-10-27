module CatalogAdmin::ItemTypesHelper
  def setup_item_type_nav_link(item_type)
    slug = params[:item_type_slug] || params[:slug]
    active = params[:controller] =~ /item_types|fields/ &&
             slug == item_type.slug

    klass = "list-group-item"
    klass << " active" if active

    link_to(
      item_type.name_primary,
      catalog_admin_item_type_fields_path(item_type.catalog, item_type),
      :class => klass
    )
  end

  def entry_item_type_nav_link(item_type)
    slug = params[:item_type_slug] || params[:slug]
    active = params[:controller] == "catalog_admin/items" &&
             slug == item_type.slug

    klass = "list-group-item"
    klass << " active" if active

    label = [h(item_type.name_plural_primary)]
    label << content_tag(
      :span,
      number_with_delimiter(item_type.items.count),
      :class => "badge"
    )

    link_to(
      label.join(" ").html_safe,
      catalog_admin_items_path(item_type.catalog, item_type),
      :class => klass
    )
  end
end
