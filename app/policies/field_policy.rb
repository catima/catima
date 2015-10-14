# Note that this policy is only for *management* of Fields. All users can
# of course view fields, since they are all public.
class FieldPolicy
  attr_reader :user, :field
  delegate :catalog, :to => :field

  def initialize(user, field)
    @user = user
    @field = field
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
