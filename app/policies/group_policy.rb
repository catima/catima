class GroupPolicy
  def initialize(user, group)
    @user = user
    @group = group
  end

  def own_group?
    @user == @group.owner
  end

  alias_method :show?, :own_group?
  alias_method :edit?, :own_group?
  alias_method :update?, :own_group?
  alias_method :destroy?, :own_group?
end
