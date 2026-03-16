require "test_helper"

class GroupPolicyTest < ActiveSupport::TestCase
  test "#index? allows catalog admin" do
    assert policy(users(:one_admin), groups(:one)).index?
  end

  test "#index? allows system admin" do
    assert policy(users(:system_admin), groups(:one)).index?
  end

  test "#index? denies catalog editor" do
    refute policy(users(:one_editor), groups(:one)).index?
  end

  test "#index? denies admin of a different catalog" do
    # two_admin is admin of catalog :two, not catalog :one
    refute policy(users(:two_admin), groups(:one)).index?
  end

  test "#index? denies plain user" do
    refute policy(users(:one), groups(:one)).index?
  end

  test "#index? denies guest" do
    refute policy(Guest.new, groups(:one)).index?
  end

  test "#new? allows catalog admin" do
    assert policy(users(:one_admin), groups(:one)).new?
  end

  test "#new? allows system admin" do
    assert policy(users(:system_admin), groups(:one)).new?
  end

  test "#new? denies catalog editor" do
    refute policy(users(:one_editor), groups(:one)).new?
  end

  test "#new? denies admin of a different catalog" do
    refute policy(users(:two_admin), groups(:one)).new?
  end

  test "#create? allows catalog admin" do
    assert policy(users(:one_admin), groups(:one)).create?
  end

  test "#create? allows system admin" do
    assert policy(users(:system_admin), groups(:one)).create?
  end

  test "#create? denies catalog editor" do
    refute policy(users(:one_editor), groups(:one)).create?
  end

  test "#create? denies admin of a different catalog" do
    refute policy(users(:two_admin), groups(:one)).create?
  end

  test "#create? denies plain user" do
    refute policy(users(:one), groups(:one)).create?
  end

  test "#show? allows catalog admin and denies editor" do
    assert policy(users(:one_admin), groups(:one)).show?
    refute policy(users(:one_editor), groups(:one)).show?
  end

  test "#edit? allows catalog admin and denies editor" do
    assert policy(users(:one_admin), groups(:one)).edit?
    refute policy(users(:one_editor), groups(:one)).edit?
  end

  test "#update? allows catalog admin and denies editor" do
    assert policy(users(:one_admin), groups(:one)).update?
    refute policy(users(:one_editor), groups(:one)).update?
  end

  test "#destroy? allows catalog admin and denies editor" do
    assert policy(users(:one_admin), groups(:one)).destroy?
    refute policy(users(:one_editor), groups(:one)).destroy?
  end

  test "admin of catalog one cannot manage groups in catalog two" do
    refute policy(users(:one_admin), groups(:two)).show?
    refute policy(users(:one_admin), groups(:two)).edit?
    refute policy(users(:one_admin), groups(:two)).update?
    refute policy(users(:one_admin), groups(:two)).destroy?
  end

  private

  def policy(user, group=groups(:one))
    GroupPolicy.new(user, group)
  end
end
