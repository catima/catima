class ContactMailer < ApplicationMailer
  def send_request(receiver, content, catalog_name, catalog_url)
    @content = content
    @catalog_name = catalog_name
    @catalog_url = catalog_url

    mail(
      :subject => "[Catima] - #{content['subject']}",
      :reply_to => content['email'],
      :to => receiver,
      :from => ENV['MAIL_SENDER'],
      :template_name => "contact"
    )
  ensure
    I18n.locale = I18n.default_locale
  end
end
