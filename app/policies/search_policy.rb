class SearchPolicy
  attr_reader :user, :search

  def initialize(user, search)
    @user = user
    @search = search
  end

  def create?
    return false unless @user.authenticated?

    @user.catalog_visible_for_role?(@search.related_search.catalog)
  end

  def destroy?
    return false unless @user.authenticated?

    attributed_to_user?
  end

  alias_method :show?, :create?
  alias_method :edit?, :create?
  alias_method :update?, :create?

  private

  def attributed_to_user?
    @search.user == @user
  end
end
