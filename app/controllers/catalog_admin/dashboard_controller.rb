class CatalogAdmin::DashboardController < CatalogAdmin::BaseController
  def data
    if (first_type = catalog.item_types.first)
      redirect_to(catalog_admin_items_path(catalog, I18n.locale, first_type))
    else
      render("data")
    end
  end

  def setup
    return redirect_to(catalog_admin_data_path) unless policy(ItemType).index?

    if (first_type = catalog.item_types.first)
      redirect_to(catalog_admin_item_type_fields_path(catalog, I18n.locale, first_type))
    else
      redirect_to(catalog_admin_settings_path(catalog, I18n.locale))
    end
  end

  protected

  # Avoid login an event for the catalog admin dashboard.
  # An other catalog admin controller will do the job.
  def track_action
  end
end
