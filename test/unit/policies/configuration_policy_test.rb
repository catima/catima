require "test_helper"

class ConfigurationPolicyTest < ActiveSupport::TestCase
  test "system admin can update" do
    assert(policy(users(:system_admin)).update?)
  end

  test "other users cannot update" do
    refute(policy(Guest.new).update?)
    refute(policy(users(:one)).update?)
  end

  private

  def policy(user)
    ConfigurationPolicy.new(user, configurations(:one))
  end
end
