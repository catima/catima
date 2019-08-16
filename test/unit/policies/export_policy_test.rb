require "test_helper"

class ExportPolicyTest < ActiveSupport::TestCase
  test "#create? allows admins of the catalog" do
    refute(policy(Guest.new, exports(:one)).create?)
    refute(policy(users(:one), exports(:one)).create?)
    refute(policy(users(:one_member), exports(:one)).create?)
    refute(policy(users(:one_editor), exports(:one)).create?)
    refute(policy(users(:one_super_editor), exports(:one)).create?)
    refute(policy(users(:one_reviewer), exports(:one)).create?)
    refute(policy(users(:one_admin), exports(:two)).create?)
    assert(policy(users(:one_admin), exports(:one)).create?)
    assert(policy(users(:system_admin), exports(:one)).create?)
  end

  test "#create? allows system admins for csv & sql formats" do
    refute(policy(users(:one_admin), exports(:one_csv)).create?)
    refute(policy(users(:one_admin), exports(:one_sql)).create?)
    assert(policy(users(:system_admin), exports(:one_csv)).create?)
    assert(policy(users(:system_admin), exports(:one_sql)).create?)
  end

  test "#download? allows admins of the catalog" do
    refute(policy(Guest.new, exports(:one)).download?)
    refute(policy(users(:one), exports(:one)).download?)
    refute(policy(users(:one_member), exports(:one)).download?)
    refute(policy(users(:one_editor), exports(:one)).download?)
    refute(policy(users(:one_super_editor), exports(:one)).download?)
    refute(policy(users(:one_reviewer), exports(:one)).download?)
    refute(policy(users(:one_admin), exports(:two)).download?)
    assert(policy(users(:one_admin), exports(:one)).download?)
    assert(policy(users(:system_admin), exports(:one)).download?)
  end

  test "#download? only if export is valid, ready and has file" do
    refute(policy(users(:one_admin), exports(:one_expired)).download?)
    refute(policy(users(:one_admin), exports(:one_processing)).download?)
    refute(policy(users(:one_admin), exports(:one_error)).download?)
    assert(policy(users(:one_admin), exports(:one)).download?)
  end

  test "#index? allows admins of the catalog" do
    refute(policy(Guest.new, exports(:one)).index?)
    refute(policy(users(:one), exports(:one)).index?)
    refute(policy(users(:one_member), exports(:one)).index?)
    refute(policy(users(:one_editor), exports(:one)).index?)
    refute(policy(users(:one_super_editor), exports(:one)).index?)
    refute(policy(users(:one_reviewer), exports(:one)).index?)
    refute(policy(users(:one_admin), exports(:two)).index?)
    assert(policy(users(:one_admin), exports(:one)).index?)
    assert(policy(users(:system_admin), exports(:one)).index?)
  end

  def policy(user, export=exports(:one))
    ExportPolicy.new(user, export)
  end
end
