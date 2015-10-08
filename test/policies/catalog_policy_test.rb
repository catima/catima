require "test_helper"

class CatalogPolicyTest < ActiveSupport::TestCase
  test "system admin do everything" do
    assert(policy(users(:system_admin), nil).index?)
    assert(policy(users(:system_admin)).create?)
    assert(policy(users(:system_admin)).edit?)
    assert(policy(users(:system_admin)).new?)
    assert(policy(users(:system_admin)).update?)
  end

  test "other users can do nothing" do
    refute(policy(users(:one_admin), nil).index?)
    refute(policy(users(:one_admin)).create?)
    refute(policy(users(:one_admin)).edit?)
    refute(policy(users(:one_admin)).new?)
    refute(policy(users(:one_admin)).update?)

    refute(policy(Guest.new, nil).index?)
    refute(policy(Guest.new).create?)
    refute(policy(Guest.new).edit?)
    refute(policy(Guest.new).new?)
    refute(policy(Guest.new).update?)
  end

  private

  def policy(user, catalog=catalogs(:one))
    CatalogPolicy.new(user, catalog)
  end
end
