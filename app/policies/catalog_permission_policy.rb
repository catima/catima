class CatalogPermissionPolicy
  def initialize(user, catalog_permission)
    @user = user
    @catalog_permission = catalog_permission
  end

  def update?
    @user.catalog_role_at_least?(@catalog_permission.catalog, 'admin')
  end
end
