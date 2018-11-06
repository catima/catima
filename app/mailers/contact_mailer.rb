class ContactMailer < ApplicationMailer
  def send_request(receiver, content, catalog)
    @content = content
    @catalog = catalog

    subject = content['subject'].empty? ? t('contact_mailer.subject') : content['subject']

    mail(
      :subject => "[Catima] - #{subject}",
      :reply_to => content['email'],
      :to => receiver,
      :from => ENV['MAIL_SENDER'],
      :template_name => "contact"
    )
  ensure
    I18n.locale = I18n.default_locale
  end
end
