require "test_helper"

class MessageDismissalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @message = Message.create!(
      text: "Test message",
      severity: "info",
      scope: "all",
      active: true
    )
  end

  test "dismissing a message stores it in session" do
    post dismiss_message_path(@message)

    assert_response :success
    assert_includes session[:dismissed_messages], @message.id
  end

  test "dismissing multiple messages stores all IDs" do
    message2 = Message.create!(text: "Second", active: true)
    message3 = Message.create!(text: "Third", active: true)

    post dismiss_message_path(@message)
    post dismiss_message_path(message2)
    post dismiss_message_path(message3)

    assert_equal 3, session[:dismissed_messages].length
    assert_includes session[:dismissed_messages], @message.id
    assert_includes session[:dismissed_messages], message2.id
    assert_includes session[:dismissed_messages], message3.id
  end

  test "dismissing same message twice only stores it once" do
    post dismiss_message_path(@message)
    post dismiss_message_path(@message)

    assert_equal 1, session[:dismissed_messages].count(@message.id)
  end

  test "dismissal works for anonymous users" do
    # Don't log in - test as anonymous
    post dismiss_message_path(@message)

    assert_response :success
    assert_includes session[:dismissed_messages], @message.id
  end

  test "dismissal works for authenticated users" do
    log_in_as("one-owner@example.com", "password")

    post dismiss_message_path(@message)

    assert_response :success
    assert_includes session[:dismissed_messages], @message.id
  end

  test "dismissing non-existent message ID still succeeds" do
    post dismiss_message_path(id: 99_999)

    assert_response :success
    assert_includes session[:dismissed_messages], 99_999
  end

  test "session persists across multiple requests" do
    post dismiss_message_path(@message)

    # Make another request
    get root_path

    # Session should still contain dismissed message
    assert_includes session[:dismissed_messages], @message.id
  end
end
