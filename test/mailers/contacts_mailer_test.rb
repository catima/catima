require "test_helper"

class ContactsMailerTest < ActionMailer::TestCase
  test "send_request" do
    receiver = 'admin_email@email.ch'
    request_params = {
      "name" => "fake name",
      "email" => "email@email.com",
      "subject" => "my contact request",
      "body" => "request body"
    }

    catalog = Catalog.new(
      :name => 'Catalog',
      :slug => 'catalog'
    )

    mail = ContactMailer.send_request(receiver, request_params, catalog)

    assert_match(request_params['subject'], mail.subject)
    assert_equal([ENV['MAIL_SENDER']], mail.from)
    assert_equal([request_params['email']], mail.reply_to)
    assert_equal([receiver], mail.to)
    assert_match(/request body/i, mail.body.encoded.squish)
  end
end
