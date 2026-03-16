require "test_helper"

class APIKeyPolicyTest < ActiveSupport::TestCase
  test "#create? allows catalog admin" do
    assert policy(users(:one_admin), api_keys(:one)).create?
  end

  test "#create? allows system admin" do
    assert policy(users(:system_admin), api_keys(:one)).create?
  end

  test "#create? denies catalog editor" do
    refute policy(users(:one_editor), api_keys(:one)).create?
  end

  test "#create? denies catalog member" do
    refute policy(users(:one_member), api_keys(:one)).create?
  end

  test "#create? denies plain user" do
    refute policy(users(:one), api_keys(:one)).create?
  end

  test "#create? denies admin of a different catalog" do
    refute policy(users(:two_admin), api_keys(:one)).create?
  end

  test "#update? allows catalog admin" do
    assert policy(users(:one_admin), api_keys(:one)).update?
  end

  test "#update? allows system admin" do
    assert policy(users(:system_admin), api_keys(:one)).update?
  end

  test "#update? denies catalog editor" do
    refute policy(users(:one_editor), api_keys(:one)).update?
  end

  test "#update? denies admin of a different catalog" do
    refute policy(users(:two_admin), api_keys(:one)).update?
  end

  test "#destroy? allows catalog admin" do
    assert policy(users(:one_admin), api_keys(:one)).destroy?
  end

  test "#destroy? allows system admin" do
    assert policy(users(:system_admin), api_keys(:one)).destroy?
  end

  test "#destroy? denies catalog editor" do
    refute policy(users(:one_editor), api_keys(:one)).destroy?
  end

  test "#destroy? denies admin of a different catalog" do
    refute policy(users(:two_admin), api_keys(:one)).destroy?
  end

  test "admin of catalog one cannot create/update/destroy keys in catalog two" do
    refute policy(users(:one_admin), api_keys(:two)).create?
    refute policy(users(:one_admin), api_keys(:two)).update?
    refute policy(users(:one_admin), api_keys(:two)).destroy?
  end

  private

  def policy(user, api_key=api_keys(:one))
    APIKeyPolicy.new(user, api_key)
  end
end
