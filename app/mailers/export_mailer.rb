class ExportMailer < ApplicationMailer
  def send_message(export)
    I18n.locale = export.user.primary_language
    @export = export

    mail(
      :subject => t("export_mailer.export.subject"),
      :to => export.user.email,
      :from => ENV['MAIL_SENDER'],
      :template_name => "export"
    )
  ensure
    I18n.locale = I18n.default_locale
  end
end
