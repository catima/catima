module CatalogAdmin::CatalogsHelper
  CATALOG_ACCESS = {
    :open_for_everyone => 1,
    :open_to_members => 2,
    :open_to_catalog_staff => 3
  }.freeze

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

  def meta_tag_description_for_catalogs(catalog)
    return if catalog.description.blank?

    tag.meta(
      name: "description",
      content: strip_tags("#{catalog.name} - #{catalog.description}")
    )
  end

  def catalog_access(catalog)
    return CATALOG_ACCESS[:open_for_everyone] if catalog.visible && !catalog.restricted
    return CATALOG_ACCESS[:open_to_members] if catalog.visible && catalog.restricted

    CATALOG_ACCESS[:open_to_catalog_staff]
  end

  def catalog_access_label(catalog)
    [:everyone, :members, :catalog_staff][catalog_access(catalog) - 1].to_s
  end

  def catalog_access_select(catalog)
    select_tag(
      :catalog_access,
      options_for_select(
        [
          [
            t('catalog_admin.catalogs.common_form_fields.open_for_everyone'),
            CATALOG_ACCESS[:open_for_everyone]
          ],
          [
            t('catalog_admin.catalogs.common_form_fields.open_to_members'),
            CATALOG_ACCESS[:open_to_members]
          ],
          [
            t('catalog_admin.catalogs.common_form_fields.open_to_catalog_staff'),
            CATALOG_ACCESS[:open_to_catalog_staff]
          ]
        ],
        catalog_access(catalog)
      ),
      class: 'form-select',
      label: 'catalog_access'
    )
  end
end
