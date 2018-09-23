class CatalogPermissionPolicy
  def initialize(user, catalog_permission)
    @user = user
    @catalog_permission = catalog_permission
  end

  def update?
    @user == @catalog_permission.group.owner
  end
end
