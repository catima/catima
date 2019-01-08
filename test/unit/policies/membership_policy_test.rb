require "test_helper"

class MembershipPolicyTest < ActiveSupport::TestCase
  test "#create? [invited] allows users when group is public reachable" do
    # Invited users joined a group with a public group identifier
    assert(policy(users(:group), memberships(:group_user_invited)).create?)
    refute(policy(users(:group_two), memberships(:group_two_user_invited)).create?)
    refute(policy(users(:group_user), memberships(:group_inactive_user_invited)).create?)
  end

  test "#create? [member] allows admins when group is active" do
    # Members are added to a group by a catalog admin
    assert(policy(users(:two_admin), memberships(:two)).create?)
    refute(policy(users(:two_user), memberships(:two_user)).create?)
    refute(policy(users(:two_admin), memberships(:group_two_inactive_user_member)).create?)
  end

  test "#destroy? allows users when group is active" do
    assert(policy(users(:one_user), memberships(:one_user)).destroy?)
    refute(policy(users(:two_user), memberships(:group_two_user_invited)).destroy?)
    refute(policy(users(:group_two), memberships(:group_two_inactive_user_member)).destroy?)
  end

  test "#destroy? allows admins when group is active" do
    assert(policy(users(:two_admin), memberships(:two_user)).destroy?)
    refute(policy(users(:two_admin), memberships(:one_user)).destroy?)
    refute(policy(users(:two_admin), memberships(:group_two_inactive_user_member)).destroy?)
  end

  def policy(user, membership)
    MembershipPolicy.new(user, membership)
  end
end
