require "test_helper"

class ReviewPolicyTest < ActiveSupport::TestCase
  test "#approve? allows reviewers and system admins" do
    refute(policy(users(:one), items(:one)).approve?)
    refute(policy(users(:one_member), items(:one)).approve?)
    refute(policy(users(:one_editor), items(:one)).approve?)
    refute(policy(users(:one_super_editor), items(:one)).approve?)
    assert(policy(users(:system_admin), items(:one)).approve?)
    assert(policy(users(:one_reviewer), items(:one)).approve?)
    refute(policy(users(:one_reviewer), items(:two)).approve?)
  end

  test "#reject? allows reviewers and system admins" do
    refute(policy(users(:one), items(:one)).reject?)
    refute(policy(users(:one_member), items(:one)).approve?)
    refute(policy(users(:one_editor), items(:one)).reject?)
    refute(policy(users(:one_super_editor), items(:one)).approve?)
    assert(policy(users(:system_admin), items(:one)).reject?)
    assert(policy(users(:one_reviewer), items(:one)).reject?)
    refute(policy(users(:one_reviewer), items(:two)).reject?)
  end

  private

  def policy(user, item=items(:one))
    ReviewPolicy.new(user, item.review)
  end
end
