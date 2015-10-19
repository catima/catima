class CatalogAdmin::DashboardController < CatalogAdmin::BaseController
  def data
    if (first_type = catalog.item_types.first)
      redirect_to(catalog_admin_items_path(catalog, first_type))
    else
      render("data")
    end
  end

  def setup
    if (first_type = catalog.item_types.first)
      redirect_to(catalog_admin_item_type_fields_path(catalog, first_type))
    else
      redirect_to(catalog_admin_users_path(catalog))
    end
  end
end
