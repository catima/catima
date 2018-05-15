class FavoritePolicy
  attr_reader :user, :favorite

  def initialize(user, favorite)
    @user = user
    @favorite = favorite
  end

  def create?
    return false unless @user.authenticated?
    @user.catalog_visible_for_role?(@favorite.item.catalog)
  end

  def destroy?
    return false unless @user.authenticated?
    attributed_to_user?
  end

  private

  def attributed_to_user?
    @favorite.user == @user
  end
end
