class MembershipPolicy
  def initialize(user, membership)
    @user = user
    @membership = membership
  end

  def catalog_admin?
    @user.catalog_role_at_least?(@membership.group.catalog, 'admin')
  end

  alias_method :new?, :catalog_admin?
  alias_method :create?, :catalog_admin?

  def destroy?
    @membership.user == @user || catalog_admin?
  end
end
