class ExportMailer < ApplicationMailer
  def send_message(export)
    @export = export

    mail(
      :subject => t("export_mailer.export.subject"),
      :to => export.user.email,
      :from => "no-reply@catima.unil.ch",
      :template_name => "export"
    )
  end
end
