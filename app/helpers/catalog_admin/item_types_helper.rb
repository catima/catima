module CatalogAdmin::ItemTypesHelper
  def setup_item_type_nav_link(item_type)
    slug = params[:item_type_slug] || params[:slug]
    active = params[:controller] =~ /item_types|fields/ &&
             slug == item_type.slug

    klass = "list-group-item list-group-item-action".dup
    klass << " active" if active

    link_to(
      item_type.name,
      catalog_admin_item_type_fields_path(item_type.catalog, I18n.locale, item_type),
      :class => klass
    )
  end

  def entry_item_type_nav_link(item_type)
    slug = params[:item_type_slug] || params[:slug]
    active = params[:controller] == "catalog_admin/items" &&
             slug == item_type.slug

    klass = "list-group-item list-group-item-action".dup
    klass << " active" if active

    label = [h(item_type.name_plural)]
    label << tag.span(
      number_with_delimiter(item_type.items.count),
      :class => "badge rounded-pill text-bg-secondary pull-right"
    )

    link_to(
      label.join(" ").html_safe,
      catalog_admin_items_path(item_type.catalog, I18n.locale, item_type),
      :class => klass
    )
  end

  def catalog_admin_contextual_data_path
    return catalog_admin_data_path unless params[:item_type_slug].present?

    catalog_admin_items_path
  end

  def catalog_admin_contextual_setup_path
    return catalog_admin_setup_path unless params[:item_type_slug].present?

    catalog_admin_item_type_fields_path
  end
end
