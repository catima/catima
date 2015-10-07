require 'test_helper'

class InvitationsMailerTest < ActionMailer::TestCase
  test "admin" do
    mail = InvitationsMailer.admin
    assert_equal "Admin", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
