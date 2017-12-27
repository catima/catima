class ItemViewPolicy
  def initialize(user, item_view)
    @user = user
    @item_view = item_view
    @item_type = item_view.item_type
  end

  def index?
    @user.system_admin? || @user.admin_of_any_catalog?
  end

  def user_is_catalog_admin?
    @user.system_admin? || @user.catalog_role_at_least?(@item_type.catalog, "admin")
  end
  alias_method :create?, :user_is_catalog_admin?
  alias_method :destroy?, :user_is_catalog_admin?
  alias_method :edit?, :user_is_catalog_admin?
  alias_method :new?, :user_is_catalog_admin?
  alias_method :show?, :user_is_catalog_admin?
  alias_method :update?, :user_is_catalog_admin?
end
