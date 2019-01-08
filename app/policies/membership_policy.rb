class MembershipPolicy
  def initialize(user, membership)
    @user = user
    @membership = membership
  end

  def catalog_admin?
    @user.catalog_role_at_least?(@membership.group.catalog, 'admin')
  end

  alias_method :new?, :catalog_admin?

  def create?
    # Membership status is "invited" if user is trying to join the group
    # with a public group identifier
    if @membership.status.eql? "invited"
      return false unless @membership.group.public_reachable?

      return @user.catalog_role_at_least?(@membership.group.catalog, 'user')
    end

    return false unless @membership.group.active?

    catalog_admin?
  end

  def destroy?
    return false unless @membership.group.active?

    @membership.user == @user || catalog_admin?
  end
end
