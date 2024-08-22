require 'test_helper'

class ExportMailerTest < ActionMailer::TestCase
  test "export" do
    export = exports(:one)
    mail = ExportMailer.send_message(export)

    assert_equal("Catima - requested export is ready", mail.subject)
    assert_equal([ENV.fetch('MAIL_SENDER', nil)], mail.from)
    assert_equal(["one-admin@example.com"], mail.to)
    assert_match("/one/en/admin/_exports/#{export.id}/download", mail.body.encoded)
  end
end
