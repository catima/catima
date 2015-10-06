# Note that this policy is only for *management* of ItemTypes. All users can
# of course view items within any item type, since they are all public.
class ItemTypePolicy
  attr_reader :user, :item_type
  delegate :catalog, :to => :item_type

  def initialize(user, item_type)
    @user = user
    @item_type = item_type
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

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.system_admin?
      ItemType.where(:catalog_id => user.admin_catalog_ids).merge(scope.all)
    end
  end
end
