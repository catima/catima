module CatalogAdmin::CategoriesHelper
  def setup_category_nav_link(category)
    id = params[:category_id] || params[:id]
    active = params[:controller] =~ /categories|fields/ &&
             id == category.to_param

    klass = "list-group-item"
    klass << " active" if active

    link_to(
      category.name,
      catalog_admin_category_fields_path(category.catalog, I18n.locale, category),
      :class => klass
    )
  end
end
