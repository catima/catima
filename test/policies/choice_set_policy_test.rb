require "test_helper"

class ChoiceSetPolicyTest < ActiveSupport::TestCase
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
      catalog = catalogs(:one)
      refute(policy(users(:one), catalog).public_send(action))
      refute(policy(Guest.new, catalog).public_send(action))
      refute(policy(users(:two), catalog).public_send(action))
      refute(policy(users(:two_admin), catalog).public_send(action))
      assert(policy(users(:one_admin), catalog).public_send(action))
      assert(policy(users(:system_admin), catalog).public_send(action))
    end
  end

  private

  def policy(user, catalog)
    ChoiceSetPolicy.new(user, ChoiceSet.new(:catalog => catalog))
  end
end
