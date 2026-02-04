require "test_helper"

# rubocop:disable Metrics/ClassLength
class MessageTest < ActiveSupport::TestCase
  should validate_presence_of(:text)
  should validate_inclusion_of(:severity).in_array(%w[info warning danger])
  should validate_inclusion_of(:scope).in_array(%w[admin public all])

  should belong_to(:catalog).optional

  test "valid message with all required fields" do
    message = Message.new(
      text: "Test message",
      severity: "info",
      scope: "all",
      active: true
    )
    assert message.valid?
  end

  test "invalid without text" do
    message = Message.new(severity: "info", scope: "all")
    refute message.valid?
    assert_includes message.errors[:text], "can't be blank"
  end

  test "invalid with incorrect severity" do
    message = Message.new(text: "Test", severity: "critical")
    refute message.valid?
    assert_includes message.errors[:severity], "is not included in the list"
  end

  test "invalid with incorrect scope" do
    message = Message.new(text: "Test", scope: "private")
    refute message.valid?
    assert_includes message.errors[:scope], "is not included in the list"
  end

  test "end date must be after start date" do
    message = Message.new(
      text: "Test",
      starts_at: 2.days.from_now,
      ends_at: 1.day.from_now
    )
    refute message.valid?
    assert_includes message.errors[:ends_at], "must be after start date"
  end

  test "valid when end date is after start date" do
    message = Message.new(
      text: "Test",
      starts_at: 1.day.from_now,
      ends_at: 2.days.from_now
    )
    message.valid?
    assert_empty message.errors[:ends_at]
  end

  test "valid when dates are nil" do
    message = Message.new(
      text: "Test",
      starts_at: nil,
      ends_at: nil
    )
    message.valid?
    assert_empty message.errors[:ends_at]
  end

  test "active? returns true when active and no dates" do
    message = Message.new(text: "Test", active: true)
    assert message.active?
  end

  test "active? returns false when not active" do
    message = Message.new(text: "Test", active: false)
    refute message.active?
  end

  test "active? returns false when start date is in future" do
    message = Message.new(text: "Test", active: true, starts_at: 1.day.from_now)
    refute message.active?
  end

  test "active? returns false when end date is in past" do
    message = Message.new(text: "Test", active: true, ends_at: 1.day.ago)
    refute message.active?
  end

  test "active? returns true when within date range" do
    message = Message.new(
      text: "Test",
      active: true,
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now
    )
    assert message.active?
  end

  test "active scope includes active messages with no dates" do
    active_message = Message.create!(
      text: "Active message",
      active: true,
      starts_at: nil,
      ends_at: nil
    )

    assert_includes Message.active, active_message
  end

  test "active scope excludes inactive messages" do
    inactive_message = Message.create!(
      text: "Inactive message",
      active: false
    )

    refute_includes Message.active, inactive_message
  end

  test "active scope excludes future messages" do
    future_message = Message.create!(
      text: "Future message",
      active: true,
      starts_at: 1.day.from_now
    )

    refute_includes Message.active, future_message
  end

  test "active scope excludes past messages" do
    past_message = Message.create!(
      text: "Past message",
      active: true,
      ends_at: 1.day.ago
    )

    refute_includes Message.active, past_message
  end

  test "active scope includes messages within date range" do
    current_message = Message.create!(
      text: "Current message",
      active: true,
      starts_at: 1.day.ago,
      ends_at: 1.day.from_now
    )

    assert_includes Message.active, current_message
  end

  test "for_admin includes admin scope messages" do
    admin_message = Message.create!(text: "Admin", scope: "admin")

    assert_includes Message.for_admin, admin_message
  end

  test "for_admin includes all scope messages" do
    all_message = Message.create!(text: "All", scope: "all")

    assert_includes Message.for_admin, all_message
  end

  test "for_admin excludes public scope messages" do
    public_message = Message.create!(text: "Public", scope: "public")

    refute_includes Message.for_admin, public_message
  end

  test "for_public includes public scope messages" do
    public_message = Message.create!(text: "Public", scope: "public")

    assert_includes Message.for_public, public_message
  end

  test "for_public includes all scope messages" do
    all_message = Message.create!(text: "All", scope: "all")

    assert_includes Message.for_public, all_message
  end

  test "for_public excludes admin scope messages" do
    admin_message = Message.create!(text: "Admin", scope: "admin")

    refute_includes Message.for_public, admin_message
  end

  test "for_catalog includes global messages" do
    global_message = Message.create!(text: "Global", catalog_id: nil)
    catalog = catalogs(:one)

    assert_includes Message.for_catalog(catalog), global_message
  end

  test "for_catalog includes catalog-specific messages" do
    catalog = catalogs(:one)
    specific_message = Message.create!(text: "Specific", catalog: catalog)

    assert_includes Message.for_catalog(catalog), specific_message
  end

  test "for_catalog excludes other catalog messages" do
    catalog_one = catalogs(:one)
    catalog_two = catalogs(:two)
    other_message = Message.create!(text: "Other", catalog: catalog_two)

    refute_includes Message.for_catalog(catalog_one), other_message
  end

  test "for_catalog with nil returns only global messages" do
    global_message = Message.create!(text: "Global", catalog_id: nil)
    specific_message = Message.create!(text: "Specific", catalog: catalogs(:one))

    results = Message.for_catalog(nil)
    assert_includes results, global_message
    refute_includes results, specific_message
  end

  test "by_severity_and_date orders danger before warning before info" do
    Message.delete_all  # Clear existing messages

    info_msg = Message.create!(text: "Info", severity: "info")
    danger_msg = Message.create!(text: "Danger", severity: "danger")
    warning_msg = Message.create!(text: "Warning", severity: "warning")

    ordered = Message.by_severity_and_date.to_a
    assert_equal danger_msg, ordered[0]
    assert_equal warning_msg, ordered[1]
    assert_equal info_msg, ordered[2]
  end

  test "by_severity_and_date orders by created_at desc within same severity" do
    Message.delete_all  # Clear existing messages

    old_info = Message.create!(text: "Old", severity: "info", created_at: 2.days.ago)
    new_info = Message.create!(text: "New", severity: "info", created_at: 1.day.ago)

    ordered = Message.where(severity: "info").by_severity_and_date.to_a
    assert_equal new_info, ordered[0]
    assert_equal old_info, ordered[1]
  end

  test "rendered_text converts markdown to html" do
    message = Message.new(text: "**Bold** and _italic_")

    assert_includes message.rendered_text, "<strong>Bold</strong>"
    assert_includes message.rendered_text, "<em>italic</em>"
  end

  test "rendered_text converts markdown headings" do
    message = Message.new(text: "# Title\n## Subtitle")

    assert_includes message.rendered_text, "<h1>Title</h1>"
    assert_includes message.rendered_text, "<h2>Subtitle</h2>"
  end

  test "rendered_text converts markdown links" do
    message = Message.new(text: "[Link](https://example.com)")

    assert_includes message.rendered_text, '<a href="https://example.com">Link</a>'
  end

  test "rendered_text converts markdown lists" do
    message = Message.new(text: "- Item 1\n- Item 2")

    assert_includes message.rendered_text, "<ul>"
    assert_includes message.rendered_text, "<li>Item 1</li>"
    assert_includes message.rendered_text, "<li>Item 2</li>"
  end

  test "rendered_text sanitizes HTML for security" do
    message = Message.new(text: '<script>alert("xss")</script>')

    # HTML should be escaped, not executed
    refute_includes message.rendered_text, "<script>"
    refute_includes message.rendered_text, "</script>"
    # The content should be safe (not contain executable script tags)
    assert message.rendered_text.include?("alert"), "Content should be present but escaped"
  end

  test "rendered_text filters dangerous HTML tags" do
    message = Message.new(text: '<iframe src="evil.com"></iframe>')

    refute_includes message.rendered_text, "<iframe"
  end

  test "rendered_text allows safe markdown with links" do
    message = Message.new(text: "Visit [our site](https://safe.com) for more info")
    rendered = message.rendered_text

    assert_includes rendered, "https://safe.com"
    refute_includes rendered, "<script>"
  end
end
# rubocop:enable Metrics/ClassLength
