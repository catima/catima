require "test_helper"

class CatalogPolicyTest < ActiveSupport::TestCase
  test "system admin do everything" do
    assert(policy(users(:system_admin), nil).index?)
    assert(policy(users(:system_admin)).create?)
    assert(policy(users(:system_admin)).edit?)
    assert(policy(users(:system_admin)).new?)
    assert(policy(users(:system_admin)).update?)
    assert(policy(users(:system_admin)).show?)
    # SystemAdmin cannot delete an active catalog
    refute(policy(users(:system_admin)).destroy?)
    # SystemAdmin can delete an inactive catalog
    assert(policy(users(:system_admin), catalogs(:inactive)).destroy?)
  end

  test "catalog admin can update but not edit, create or destroy" do
    assert(policy(users(:one_admin)).update?)
    refute(policy(users(:one_admin)).edit?)
    refute(policy(users(:one_admin), nil).index?)
    refute(policy(users(:one_admin)).create?)
    refute(policy(users(:one_admin)).new?)
    refute(policy(users(:one_admin), catalogs(:inactive)).destroy?)
  end

  test "other users cannot manage" do
    refute(policy(users(:one_admin), nil).index?)
    refute(policy(users(:one_admin)).create?)
    refute(policy(users(:one_admin)).new?)

    refute(policy(Guest.new, nil).index?)
    refute(policy(Guest.new).create?)
    refute(policy(Guest.new).edit?)
    refute(policy(Guest.new).new?)
    refute(policy(Guest.new).update?)
  end

  test "guests, users and members can't show" do
    refute(policy(users(:one)).show?)
    refute(policy(users(:two_user)).show?)
    refute(policy(users(:one_member)).show?)
    refute(policy(users(:two)).show?)
    refute(policy(users(:two_editor)).show?)
    refute(policy(users(:two_admin)).show?)
    refute(policy(Guest.new).show?)
  end

  test "editors, super-editors, reviewers, and admins of the catalog can show" do
    assert(policy(users(:one_editor)).show?)
    assert(policy(users(:one_super_editor)).show?)
    assert(policy(users(:one_reviewer)).show?)
    assert(policy(users(:one_admin)).show?)
    assert(policy(users(:one_user)).show?)
  end

  private

  def policy(user, catalog=catalogs(:one))
    CatalogPolicy.new(user, catalog)
  end
end
