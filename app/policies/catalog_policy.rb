class CatalogPolicy
  attr_reader :user, :catalog

  def initialize(user, catalog)
    @user = user
    @catalog = catalog
  end

  def user_is_system_admin?
    user.system_admin?
  end
  alias_method :create?, :user_is_system_admin?
  alias_method :destroy?, :user_is_system_admin?
  alias_method :edit?, :user_is_system_admin?
  alias_method :index?, :user_is_system_admin?
  alias_method :new?, :user_is_system_admin?
  alias_method :show?, :user_is_system_admin?
  alias_method :update?, :user_is_system_admin?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.system_admin?
      scope.none
    end
  end
end
