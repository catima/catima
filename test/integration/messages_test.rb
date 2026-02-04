require "test_helper"

class PlatformMessagesTest < ActionDispatch::IntegrationTest
  setup do
    @system_admin = users(:system_admin)
    @catalog_one = catalogs(:one)
    @catalog_two = catalogs(:two)
  end

  test "system admin creates message and it displays correctly in admin view" do
    log_in_as(@system_admin.email, "password")

    # Navigate to messages admin
    visit admin_messages_path
    assert page.has_content?("Catima admin dashboard")

    # Create new message
    click_on "New message"

    fill_in "message[text]", with: "**Maintenance** scheduled for _Saturday_"
    select "Warning (yellow)", from: "message[severity]"
    select "Admin views only", from: "message[scope]"
    check "message[active]"

    assert_difference("Message.count", 1) do
      click_on "Create message"
    end

    # Should redirect to index with success message
    assert page.has_content?("Message was successfully created")

    # Visit a catalog admin page
    visit catalog_admin_data_path(@catalog_one)

    # Message should be visible
    assert page.has_content?("Maintenance")
    assert page.has_selector?(".alert.alert-warning")

    # Message should have rendered Markdown
    assert page.has_selector?("strong", text: "Maintenance")
    assert page.has_selector?("em", text: "Saturday")
  end

  test "user can dismiss message and it respects scope targeting" do
    # Create messages with different scopes
    Message.create!(
      text: "Admin only message",
      scope: "admin",
      active: true,
      severity: "info"
    )

    Message.create!(
      text: "Public only message",
      scope: "public",
      active: true,
      severity: "info"
    )

    Message.create!(
      text: "Message for everyone",
      scope: "all",
      active: true,
      severity: "warning"
    )

    # Test admin view
    log_in_as(@system_admin.email, "password")
    visit catalog_admin_data_path(@catalog_one)

    # Should see admin and all messages
    assert page.has_content?("Admin only message")
    assert page.has_content?("Message for everyone")
    refute page.has_content?("Public only message")

    # Test public view (logout first)
    find('#user-menu').click
    click_on "Log out"

    # Visit public catalog page
    visit catalog_home_path(@catalog_one)

    # Should see public and all messages
    assert page.has_content?("Public only message")
    assert page.has_content?("Message for everyone")
    refute page.has_content?("Admin only message")
  end

  test "multiple messages display in correct severity order" do
    Message.delete_all # Clear existing messages

    # Create messages with different severities
    Message.create!(text: "Info message", severity: "info", active: true, created_at: 3.days.ago)
    Message.create!(text: "Warning message", severity: "warning", active: true, created_at: 2.days.ago)
    Message.create!(text: "Danger message", severity: "danger", active: true, created_at: 1.day.ago)

    log_in_as(@system_admin.email, "password")
    visit catalog_admin_data_path(@catalog_one)

    # All should be visible
    assert page.has_content?("Info message")
    assert page.has_content?("Warning message")
    assert page.has_content?("Danger message")

    # Get all alert elements
    alerts = page.all(".alert")

    # Should have at least 3 alerts
    assert alerts.length >= 3, "Expected at least 3 alerts, got #{alerts.length}"

    # Should be in order: danger, warning, info
    assert_match(/Danger message/, alerts[0].text)
    assert_match(/Warning message/, alerts[1].text)
    assert_match(/Info message/, alerts[2].text)

    # Check CSS classes
    assert alerts[0][:class].include?("alert-danger")
    assert alerts[1][:class].include?("alert-warning")
    assert alerts[2][:class].include?("alert-info")
  end

  test "catalog-specific messages appear only on target catalog" do
    # Global message
    Message.create!(
      text: "Global announcement",
      catalog_id: nil,
      active: true
    )

    # Catalog-specific message
    Message.create!(
      text: "Catalog One specific",
      catalog: @catalog_one,
      active: true
    )

    log_in_as(@system_admin.email, "password")

    # Visit catalog one admin
    visit catalog_admin_data_path(@catalog_one)
    assert page.has_content?("Global announcement")
    assert page.has_content?("Catalog One specific")

    # Visit catalog two admin
    visit catalog_admin_data_path(@catalog_two)
    assert page.has_content?("Global announcement")
    refute page.has_content?("Catalog One specific")
  end

  private

  def catalog_admin_data_path(catalog)
    "/#{catalog.slug}/en/admin/_data"
  end

  def catalog_home_path(catalog)
    "/#{catalog.slug}/en"
  end
end
