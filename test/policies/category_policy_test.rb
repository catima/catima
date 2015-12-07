require "test_helper"

class CategoryPolicyTest < ActiveSupport::TestCase
  test "#index? allows catalog admins and system admins" do
    refute(policy(users(:one), nil).index?)
    refute(policy(Guest.new, nil).index?)
    refute(policy(users(:two), nil).index?)
    assert(policy(users(:one_admin), nil).index?)
    assert(policy(users(:two_admin), nil).index?)
    assert(policy(users(:system_admin), nil).index?)
  end

  %w(create? destroy? edit? new? show? update?).each do |action|
    test "#{action} allows catalog admins and system admins" do
      category = categories(:one)
      refute(policy(users(:one), category).public_send(action))
      refute(policy(Guest.new, category).public_send(action))
      refute(policy(users(:two), category).public_send(action))
      refute(policy(users(:two_admin), category).public_send(action))
      assert(policy(users(:one_admin), category).public_send(action))
      assert(policy(users(:system_admin), category).public_send(action))
    end
  end

  private

  def policy(user, category)
    CategoryPolicy.new(user, category)
  end
end
