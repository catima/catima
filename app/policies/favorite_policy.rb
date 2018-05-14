class FavoritePolicy
  attr_reader :user, :favorite

  def initialize(user, favorite)
    @user = user
    @favorite = favorite
  end

  def create?
    true
  end

  def destroy?
    attributed_to_user?
  end

  private

  def attributed_to_user?
    @favorite.user_id = @user
  end
end
