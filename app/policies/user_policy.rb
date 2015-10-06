class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def user_is_admin?
    user.system_admin? || user.admin_of_any_catalog?
  end
  alias_method :create?, :user_is_admin?
  alias_method :edit?, :user_is_admin?
  alias_method :index?, :user_is_admin?
  alias_method :new?, :user_is_admin?
  alias_method :show?, :user_is_admin?
  alias_method :update?, :user_is_admin?

  def destroy?
    user.system_admin?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.system_admin? || user.admin_of_any_catalog?
      scope.none
    end
  end
end
