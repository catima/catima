class ExportPolicy
  attr_reader :user, :catalog

  def initialize(user, catalog)
    @user = user
    @catalog = catalog
  end

  def create?
    return false unless @user.authenticated?
    return true if @user.system_admin?
    @user.catalog_role_at_least?(@catalog, "admin")
  end
end
