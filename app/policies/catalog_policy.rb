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
  alias_method :create?, :user_is_system_admin?
  alias_method :edit?, :user_is_system_admin?
  alias_method :index?, :user_is_system_admin?
  alias_method :new?, :user_is_system_admin?
  alias_method :update?, :user_is_system_admin?

  def show?
    user_is_system_admin? || user_is_catalog_admin?
  end

  private

  def user_is_catalog_admin?
    user.admin_catalog_ids.include?(catalog.id)
  end
end
