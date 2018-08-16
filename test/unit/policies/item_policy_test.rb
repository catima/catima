require "test_helper"

class ItemPolicyTest < ActiveSupport::TestCase
  test "#index? allows editors and system admins" do
    refute(policy(users(:one), nil).index?)
    refute(policy(Guest.new, nil).index?)
    assert(policy(users(:two_editor), nil).index?)
    assert(policy(users(:system_admin), nil).index?)
  end

  test "#create? allows editors and system admins" do
    refute(policy(users(:one), items(:one)).create?)
    refute(policy(users(:two_editor), items(:one)).create?)
    assert(policy(users(:two_editor), items(:two)).create?)
    assert(policy(users(:system_admin), items(:two)).create?)
  end

  test "#new? allows editors and system admins" do
    refute(policy(users(:one), items(:one)).new?)
    refute(policy(users(:two_editor), items(:one)).new?)
    assert(policy(users(:two_editor), items(:two)).new?)
    assert(policy(users(:system_admin), items(:two)).new?)
  end

  test "#show? allows editors and system admins" do
    refute(policy(users(:one), items(:one)).show?)
    refute(policy(users(:two_editor), items(:one)).show?)
    assert(policy(users(:two_editor), items(:two)).show?)
    assert(policy(users(:system_admin), items(:two)).show?)
  end

  test "#update? allows reviewers, system admins, and editors of own items" do
    refute(policy(users(:one), items(:one)).update?)
    refute(policy(users(:two_editor), items(:one)).update?)
    refute(policy(users(:two_editor), items(:two)).update?)
    assert(policy(users(:two_editor), items(:created_by_two_editor)).update?)
    assert(policy(users(:system_admin), items(:two)).update?)
  end

  test "#edit? allows reviewers, system admins, and editors of own items" do
    refute(policy(users(:one), items(:one)).edit?)
    refute(policy(users(:two_editor), items(:one)).edit?)
    refute(policy(users(:two_editor), items(:two)).edit?)
    assert(policy(users(:two_editor), items(:created_by_two_editor)).edit?)
    assert(policy(users(:system_admin), items(:two)).edit?)
  end

  test "#destroy? allows reviewers, system admins, and editors of own items" do
    refute(policy(users(:one), items(:one)).destroy?)
    refute(policy(users(:two_editor), items(:one)).destroy?)
    refute(policy(users(:two_editor), items(:two)).destroy?)
    assert(policy(users(:two_editor), items(:created_by_two_editor)).destroy?)
    assert(policy(users(:system_admin), items(:two)).destroy?)
  end

  test "Scope shows all for system admins" do
    assert_equal(Item.all.to_a, policy_scoped_items(users(:system_admin)))
  end

  test "Scope shows none for plain users and guests" do
    assert_empty(policy_scoped_items(users(:one)))
    assert_empty(policy_scoped_items(Guest.new))
  end

  test "Scope shows editor only items in her catalog" do
    assert_equal(catalogs(:two).items.to_a, policy_scoped_items(users(:two_editor)))
  end

  private

  def policy(user, item=items(:one))
    ItemPolicy.new(user, item)
  end

  def policy_scoped_items(user)
    ItemPolicy::Scope.new(user, Item).resolve.to_a
  end
end
