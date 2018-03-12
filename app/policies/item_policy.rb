# Note that this policy is only for *management* of Items. All users can
# of course view items, since they are public.
class ItemPolicy
  attr_reader :user, :item
  delegate :catalog, :to => :item

  def initialize(user, item)
    @user = user
    @item = item
  end

  def index?
    user.system_admin? || user.editor_of_any_catalog?
  end

  def create?
    role_at_least?("editor")
  end
  alias_method :new?, :create?
  alias_method :show?, :create?

  def update?
    role_at_least?(owned_item? ? "editor" : "super-editor")
  end
  alias_method :edit?, :update?
  alias_method :destroy?, :update?
  alias_method :upload?, :update?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.system_admin?
      Item.where(:catalog_id => user.editor_catalog_ids).merge(scope.all)
    end
  end

  private

  def role_at_least?(role)
    user.system_admin? || user.catalog_role_at_least?(catalog, role)
  end

  def owned_item?
    item.creator == user
  end
end
