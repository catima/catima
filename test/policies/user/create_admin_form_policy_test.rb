require "test_helper"

class User::CreateAdminFormPolicyTest < ActiveSupport::TestCase
  test "#new? allows only system admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).new?)
    refute(policy(users(:one_admin), record).new?)
    refute(policy(users(:two), record).new?)
    refute(policy(Guest.new, record).new?)
  end

  test "#create? allows only system admins" do
    record = users(:one)
    assert(policy(users(:system_admin), record).create?)
    refute(policy(users(:one_admin), record).create?)
    refute(policy(users(:two), record).create?)
    refute(policy(Guest.new, record).create?)
  end

  private

  def policy(user, record=nil)
    User::CreateAdminFormPolicy.new(user, record)
  end
end
