module CatalogAdmin::CatalogsHelper
  def setup_catalog_settings_nav_link
    active = params[:controller] == "catalog_admin/catalogs" && params[:action] == "edit"
    klass = "list-group-item  list-group-item-action"
    klass << " active" if active
    link_to(I18n.t('general'), catalog_admin_settings_path, :class => klass)
  end

  def setup_catalog_style_nav_link
    active = params[:controller] == "catalog_admin/catalogs" && params[:action] == "edit_style"
    klass = "list-group-item  list-group-item-action"
    klass << " active" if active
    link_to(I18n.t('style'), catalog_admin_style_path, :class => klass)
  end

  def setup_catalog_api_nav_link
    active = params[:controller] == "catalog_admin/catalogs" && params[:action] == "api"
    klass = "list-group-item  list-group-item-action"
    klass << " active" if active
    link_to(I18n.t('api'), catalog_admin_api_path, :class => klass)
  end

  def setup_catalog_stats_nav_link
    active = params[:controller] == "catalog_admin/catalogs" && params[:action] == "stats"
    klass = "list-group-item  list-group-item-action"
    klass << " active" if active
    link_to(I18n.t('stats'), catalog_admin_stats_path, :class => klass)
  end

  def catalog_access(catalog)
    return 1 if catalog.visible && !catalog.restricted
    return 2 if catalog.visible && catalog.restricted

    3
  end

  def catalog_access_label(catalog)
    [:everyone, :members, :catalog_staff][catalog_access(catalog) - 1].to_s
  end

  def catalog_access_select(catalog)
    select_tag(
      :catalog_access,
      options_for_select(
        [
          [t('catalog_admin.catalogs.common_form_fields.open_for_everyone'), 1],
          [t('catalog_admin.catalogs.common_form_fields.open_to_members'), 2],
          [t('catalog_admin.catalogs.common_form_fields.open_to_catalog_staff'), 3]
        ],
        catalog_access(catalog)
      ),
      class: 'form-select',
      label: 'catalog_access'
    )
  end
end
