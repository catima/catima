class MembershipPolicy
  def initialize(user, membership)
    @user = user
    @membership = membership
  end

  def own_group?
    @user == @membership.group.owner
  end

  alias_method :new?, :own_group?
  alias_method :create?, :own_group?

  def destroy?
    @membership.user == @user || @membership.group.owner == @user
  end
end
