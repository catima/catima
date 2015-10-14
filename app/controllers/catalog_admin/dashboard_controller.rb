class CatalogAdmin::DashboardController < CatalogAdmin::BaseController
  def index
    # TODO: Redirect to Data if user is not an admin
    if (first_type = catalog.item_types.first)
      redirect_to(catalog_admin_item_type_fields_path(catalog, first_type))
    else
      redirect_to(catalog_admin_users_path(catalog))
    end
  end
end
