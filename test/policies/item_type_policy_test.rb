require "test_helper"

class ItemTypePolicyTest < ActiveSupport::TestCase
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
      item_type = item_types(:one)
      refute(policy(users(:one), item_type).public_send(action))
      refute(policy(Guest.new, item_type).public_send(action))
      refute(policy(users(:two), item_type).public_send(action))
      refute(policy(users(:two_admin), item_type).public_send(action))
      assert(policy(users(:one_admin), item_type).public_send(action))
      assert(policy(users(:system_admin), item_type).public_send(action))
    end
  end

  private

  def policy(user, item_type)
    ItemTypePolicy.new(user, item_type)
  end
end
