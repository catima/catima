class GroupPolicy
  def initialize(user, group)
    @user = user
    @group = group
  end

  def admin?
    # All catalog admins of the catalog the group belongs to
    # are considered as group admins.
    @user.catalog_role_at_least?(@group.catalog, 'admin', false)
  end

  alias_method :show?, :admin?
  alias_method :edit?, :admin?
  alias_method :update?, :admin?
  alias_method :destroy?, :admin?
end
