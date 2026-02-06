require "test_helper"

class MessagePolicyTest < ActiveSupport::TestCase
  setup do
    @system_admin = users(:system_admin)
    @catalog_admin = users(:one_admin)
    @regular_user = users(:one_user)
    @guest = Guest.new
    @message = Message.create!(text: "Test message")
  end

  test "system admin can view message index" do
    policy = MessagePolicy.new(@system_admin, Message)
    assert policy.index?
  end

  test "catalog admin cannot view message index" do
    policy = MessagePolicy.new(@catalog_admin, Message)
    refute policy.index?
  end

  test "regular user cannot view message index" do
    policy = MessagePolicy.new(@regular_user, Message)
    refute policy.index?
  end

  test "guest cannot view message index" do
    policy = MessagePolicy.new(@guest, Message)
    refute policy.index?
  end

  test "system admin can create messages" do
    policy = MessagePolicy.new(@system_admin, @message)
    assert policy.create?
  end

  test "catalog admin cannot create messages" do
    policy = MessagePolicy.new(@catalog_admin, @message)
    refute policy.create?
  end

  test "regular user cannot create messages" do
    policy = MessagePolicy.new(@regular_user, @message)
    refute policy.create?
  end

  test "guest cannot create messages" do
    policy = MessagePolicy.new(@guest, @message)
    refute policy.create?
  end

  test "system admin can update messages" do
    policy = MessagePolicy.new(@system_admin, @message)
    assert policy.update?
  end

  test "catalog admin cannot update messages" do
    policy = MessagePolicy.new(@catalog_admin, @message)
    refute policy.update?
  end

  test "regular user cannot update messages" do
    policy = MessagePolicy.new(@regular_user, @message)
    refute policy.update?
  end

  test "guest cannot update messages" do
    policy = MessagePolicy.new(@guest, @message)
    refute policy.update?
  end

  test "system admin can destroy messages" do
    policy = MessagePolicy.new(@system_admin, @message)
    assert policy.destroy?
  end

  test "catalog admin cannot destroy messages" do
    policy = MessagePolicy.new(@catalog_admin, @message)
    refute policy.destroy?
  end

  test "regular user cannot destroy messages" do
    policy = MessagePolicy.new(@regular_user, @message)
    refute policy.destroy?
  end

  test "guest cannot destroy messages" do
    policy = MessagePolicy.new(@guest, @message)
    refute policy.destroy?
  end
end
