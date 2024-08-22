require "test_helper"

class InvitationsMailerTest < ActionMailer::TestCase
  test "catalog_admin" do
    user = users(:two_admin)
    mail = InvitationsMailer.admin(user, "__test_token__")

    assert_match(/invitation for two/i, mail.subject)
    assert_equal([ENV.fetch('MAIL_SENDER', nil)], mail.from)
    assert_equal(["system-admin@example.com"], mail.reply_to)
    assert_equal(["two-admin@example.com"], mail.to)
    assert_match(/administrator of the two catalog/i, mail.body.encoded.squish)
    assert_match("reset_password_token=__test_token__", mail.body.encoded)
  end

  test "system_admin" do
    user = users(:system_admin_invited_by_one)
    mail = InvitationsMailer.admin(user, "__test_token__")

    assert_match(/system administrator invitation/i, mail.subject)
    assert_equal([ENV.fetch('MAIL_SENDER', nil)], mail.from)
    assert_equal(["one@example.com"], mail.reply_to)
    assert_equal(["system-admin-invited-by-one@example.com"], mail.to)
    assert_match(/invited you to be a system administrator/, mail.body.encoded)
    assert_match("reset_password_token=__test_token__", mail.body.encoded)
  end
end
