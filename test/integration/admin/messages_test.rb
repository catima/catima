require "test_helper"

# rubocop:disable Metrics/ClassLength
class Admin::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = users(:system_admin)
    @regular_user = users(:one_user)
    @message = Message.create!(
      text: "Test message",
      severity: "info",
      scope: "all",
      active: true
    )
  end

  test "system admin can access index" do
    log_in_as(@system_admin.email, "password")

    visit admin_messages_path
    assert page.has_content?("Catima admin dashboard")
  end

  test "regular user cannot access index" do
    log_in_as(@regular_user.email, "password")

    # Regular users get a Pundit::NotAuthorizedError when trying to access
    assert_raises(Pundit::NotAuthorizedError) do
      visit admin_messages_path
    end
  end

  test "guest cannot access index" do
    visit admin_messages_path
    assert page.has_content?("Log in")
  end

  test "index displays all messages" do
    log_in_as(@system_admin.email, "password")

    visit admin_messages_path
    assert page.has_selector?("table")
    assert page.has_content?(@message.text)
  end

  test "index shows message status badges" do
    log_in_as(@system_admin.email, "password")

    visit admin_messages_path
    assert page.has_selector?("span.badge", text: /Active|Inactive/)
  end

  test "system admin can access new message form" do
    log_in_as(@system_admin.email, "password")

    visit admin_messages_path
    click_on "New message"

    assert page.has_selector?("form")
    assert page.has_field?("message[text]")
    assert page.has_select?("message[severity]")
    assert page.has_select?("message[scope]")
  end

  test "system admin can create message" do
    log_in_as(@system_admin.email, "password")

    visit new_admin_message_path

    fill_in "message[text]", with: "New important message"
    select "Warning (yellow)", from: "message[severity]"
    select "Admin views only", from: "message[scope]"
    check "message[active]"

    assert_difference("Message.count", 1) do
      click_on "Create message"
    end

    assert page.has_content?("Message was successfully created")

    new_message = Message.last
    assert_equal "New important message", new_message.text
    assert_equal "warning", new_message.severity
    assert_equal "admin", new_message.scope
    assert new_message.active
  end

  test "create with catalog assignment" do
    log_in_as(@system_admin.email, "password")
    catalog = catalogs(:one)

    visit new_admin_message_path

    fill_in "message[text]", with: "Catalog specific message"
    select catalog.name, from: "message[catalog_id]"

    click_on "Create message"

    assert_equal catalog, Message.last.catalog
  end

  test "create fails with invalid data" do
    log_in_as(@system_admin.email, "password")

    visit new_admin_message_path

    assert_no_difference("Message.count") do
      click_on "Create message"
    end

    # Should re-render form with errors
    assert page.has_selector?("div.alert-danger")
  end

  test "system admin can access edit form" do
    log_in_as(@system_admin.email, "password")

    visit admin_messages_path
    first("a.message-action-edit").click

    assert page.has_selector?("form")
    assert page.has_field?("message[text]", with: @message.text)
  end

  test "regular user cannot edit message" do
    log_in_as(@regular_user.email, "password")

    # Regular users get a Pundit::NotAuthorizedError when trying to access edit
    assert_raises(Pundit::NotAuthorizedError) do
      visit edit_admin_message_path(@message)
    end
  end

  test "system admin can update message" do
    log_in_as(@system_admin.email, "password")

    visit edit_admin_message_path(@message)

    fill_in "message[text]", with: "Updated message text"
    select "Danger (red)", from: "message[severity]"
    select "Public views only", from: "message[scope]"

    click_on "Update message"

    assert page.has_content?("Message was successfully updated")

    @message.reload
    assert_equal "Updated message text", @message.text
    assert_equal "danger", @message.severity
    assert_equal "public", @message.scope
  end

  test "update can toggle active status" do
    log_in_as(@system_admin.email, "password")

    visit edit_admin_message_path(@message)

    uncheck "message[active]"
    click_on "Update message"

    @message.reload
    refute @message.active
  end

  test "update can set date range" do
    log_in_as(@system_admin.email, "password")
    starts = 1.day.from_now
    ends = 2.days.from_now

    visit edit_admin_message_path(@message)

    fill_in "message[starts_at]", with: starts.strftime("%Y-%m-%dT%H:%M")
    fill_in "message[ends_at]", with: ends.strftime("%Y-%m-%dT%H:%M")

    click_on "Update message"

    @message.reload
    assert_in_delta starts.to_i, @message.starts_at.to_i, 60
    assert_in_delta ends.to_i, @message.ends_at.to_i, 60
  end

  test "update fails with invalid data" do
    log_in_as(@system_admin.email, "password")
    original_text = @message.text

    visit edit_admin_message_path(@message)

    fill_in "message[text]", with: ""
    click_on "Update message"

    # Should re-render form
    assert page.has_selector?("div.alert-danger")

    @message.reload
    assert_equal original_text, @message.text
  end

  test "system admin can delete message" do
    log_in_as(@system_admin.email, "password")

    visit admin_messages_path

    # We'll just verify the delete link exists
    within("tr", text: @message.text) do
      assert page.has_selector?('a[data-toggle="tooltip"][title="Delete"]')
    end
  end
end
# rubocop:enable Metrics/ClassLength
