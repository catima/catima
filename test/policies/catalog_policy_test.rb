require "test_helper"

class CatalogPolicyTest < ActiveSupport::TestCase
  test "system admin do everything" do
    assert(policy(users(:system_admin), nil).index?)
    assert(policy(users(:system_admin)).create?)
    assert(policy(users(:system_admin)).destroy?)
    assert(policy(users(:system_admin)).edit?)
    assert(policy(users(:system_admin)).new?)
    assert(policy(users(:system_admin)).show?)
    assert(policy(users(:system_admin)).update?)
    assert_equal(Catalog.all.to_a, policy_scoped_catalogs(users(:system_admin)))
  end

  test "other users can do nothing" do
    refute(policy(users(:one_admin), nil).index?)
    refute(policy(users(:one_admin)).create?)
    refute(policy(users(:one_admin)).destroy?)
    refute(policy(users(:one_admin)).edit?)
    refute(policy(users(:one_admin)).new?)
    refute(policy(users(:one_admin)).show?)
    refute(policy(users(:one_admin)).update?)
    assert_empty(policy_scoped_catalogs(users(:one_admin)))

    refute(policy(Guest.new, nil).index?)
    refute(policy(Guest.new).create?)
    refute(policy(Guest.new).destroy?)
    refute(policy(Guest.new).edit?)
    refute(policy(Guest.new).new?)
    refute(policy(Guest.new).show?)
    refute(policy(Guest.new).update?)
    assert_empty(policy_scoped_catalogs(Guest.new))
  end

  private

  def policy(user, catalog=catalogs(:one))
    CatalogPolicy.new(user, catalog)
  end

  def policy_scoped_catalogs(user)
    CatalogPolicy::Scope.new(user, Catalog).resolve
  end
end
