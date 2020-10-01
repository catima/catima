# Note that this policy is only for *management* of menu items.
# All users can of course view menu items, since they are public.
class MenuItemPolicy
  attr_reader :user, :menu_item

  delegate :catalog, :to => :menu_item

  def initialize(user, menu_item)
    @user = user
    @menu_item = menu_item
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
