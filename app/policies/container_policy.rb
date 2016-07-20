# Note that this policy is only for *management* of Containers. All users can
# of course view containers, since they are public.
class ContainerPolicy
  attr_reader :user, :container
  delegate :catalog, :to => :container

  def initialize(user, container)
    @user = user
    @container = container
  end

  def index?
    user.system_admin? || user.admin_of_any_catalog?
  end

  def user_is_catalog_admin?
    user.system_admin? || user.catalog_role_at_least?(catalog, "admin")
  end
  alias_method :create?, :user_is_catalog_admin?
  alias_method :destroy?, :user_is_catalog_admin?
  alias_method :edit?, :user_is_catalog_admin?
  alias_method :new?, :user_is_catalog_admin?
  alias_method :show?, :user_is_catalog_admin?
  alias_method :update?, :user_is_catalog_admin?
end
