# Note that this policy is only for *management* of Catalogs. All users can
# of course view catalogs, since they are public.
class CatalogPolicy
  attr_reader :user, :catalog

  def initialize(user, catalog)
    @user = user
    @catalog = catalog
  end

  def user_is_system_admin?
    user.system_admin?
  end

  def user_is_catalog_admin?
    user.system_admin? || user.catalog_role_at_least?(catalog, "admin")
  end

  def user_is_at_least_an_editor?
    user_is_system_admin? || user.catalog_role_at_least?(catalog, "editor")
  end

  def user_is_at_least_a_member?
    user_is_system_admin? || user.catalog_role_at_least?(catalog, "member")
  end

  def destroy?
    return false unless user_is_system_admin?

    return false if @catalog.active?

    true
  end

  alias_method :create?, :user_is_system_admin?
  alias_method :edit?, :user_is_catalog_admin?
  alias_method :index?, :user_is_system_admin?
  alias_method :new?, :user_is_system_admin?
  alias_method :update?, :user_is_catalog_admin?
  alias_method :update_style?, :user_is_catalog_admin?
  alias_method :show?, :user_is_at_least_an_editor?
  alias_method :setup?, :user_is_catalog_admin?
end
