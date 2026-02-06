require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  setup do
    @catalog_one = catalogs(:one)
    @catalog_two = catalogs(:two)
  end

  test "current_messages returns active admin messages for admin context" do
    admin_msg = Message.create!(text: "Admin", scope: "admin", active: true)
    public_msg = Message.create!(text: "Public", scope: "public", active: true)
    all_msg = Message.create!(text: "All", scope: "all", active: true)

    messages = current_messages(:admin, @catalog_one)

    assert_includes messages, admin_msg
    assert_includes messages, all_msg
    refute_includes messages, public_msg
  end

  test "current_messages returns active public messages for public context" do
    admin_msg = Message.create!(text: "Admin", scope: "admin", active: true)
    public_msg = Message.create!(text: "Public", scope: "public", active: true)
    all_msg = Message.create!(text: "All", scope: "all", active: true)

    messages = current_messages(:public, @catalog_one)

    assert_includes messages, public_msg
    assert_includes messages, all_msg
    refute_includes messages, admin_msg
  end

  test "current_messages excludes inactive messages" do
    active_msg = Message.create!(text: "Active", active: true)
    inactive_msg = Message.create!(text: "Inactive", active: false)

    messages = current_messages(:admin, @catalog_one)

    assert_includes messages, active_msg
    refute_includes messages, inactive_msg
  end

  test "current_messages excludes dismissed messages" do
    msg1 = Message.create!(text: "Message 1", active: true)
    msg2 = Message.create!(text: "Message 2", active: true)

    session[:dismissed_messages] = [msg1.id]

    messages = current_messages(:admin, @catalog_one)

    refute_includes messages, msg1
    assert_includes messages, msg2
  end

  test "current_messages includes global messages for any catalog" do
    global_msg = Message.create!(text: "Global", catalog_id: nil, active: true)

    messages_one = current_messages(:admin, @catalog_one)
    messages_two = current_messages(:admin, @catalog_two)

    assert_includes messages_one, global_msg
    assert_includes messages_two, global_msg
  end

  test "current_messages includes catalog-specific messages only for that catalog" do
    specific_msg = Message.create!(
      text: "Specific",
      catalog: @catalog_one,
      active: true
    )

    messages_one = current_messages(:admin, @catalog_one)
    messages_two = current_messages(:admin, @catalog_two)

    assert_includes messages_one, specific_msg
    refute_includes messages_two, specific_msg
  end

  test "current_messages orders by severity then date" do
    Message.delete_all # Clear existing messages from fixtures

    info_msg = Message.create!(text: "Info", severity: "info", active: true, created_at: 3.days.ago)
    warning_msg = Message.create!(text: "Warning", severity: "warning", active: true, created_at: 2.days.ago)
    danger_msg = Message.create!(text: "Danger", severity: "danger", active: true, created_at: 1.day.ago)

    messages = current_messages(:admin, @catalog_one)

    assert_equal danger_msg, messages[0]
    assert_equal warning_msg, messages[1]
    assert_equal info_msg, messages[2]
  end

  test "current_messages returns empty array when no active messages" do
    Message.destroy_all

    messages = current_messages(:admin, @catalog_one)

    assert_empty messages
  end

  test "current_messages handles nil session" do
    session[:dismissed_messages] = nil
    msg = Message.create!(text: "Test", active: true)

    messages = current_messages(:admin, @catalog_one)

    assert_includes messages, msg
  end
end
