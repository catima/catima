class ContactMailer < ApplicationMailer
  def send_request(receiver, content)
    @content = content

    mail(
      :subject => content['subject'],
      :reply_to => content['email'],
      :to => receiver,
      :from => ENV['MAIL_SENDER'],
      :template_name => "contact"
    )
  ensure
    I18n.locale = I18n.default_locale
  end
end
