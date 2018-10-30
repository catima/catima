class ContactMailer < ApplicationMailer
  def send_message(content, email)
    # I18n.locale = export.user.primary_language

    @content = content

    mail(
      :subject => content['subject'],
      :to => email,
      :from => ENV['MAIL_SENDER'],
      :template_name => "contact"
    )
  ensure
    I18n.locale = I18n.default_locale
  end
end
