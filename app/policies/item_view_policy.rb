class ItemViewPolicy
  def initialize(user, item_view)
    @user = user
    @item_view = item_view
    @item_type = item_view.item_type
  end

  def index?
    @user.system_admin?
  end

  def user_is_system_admin?
    @user.system_admin?
  end
  alias_method :create?, :user_is_system_admin?
  alias_method :destroy?, :user_is_system_admin?
  alias_method :edit?, :user_is_system_admin?
  alias_method :new?, :user_is_system_admin?
  alias_method :show?, :user_is_system_admin?
  alias_method :update?, :user_is_system_admin?
end
