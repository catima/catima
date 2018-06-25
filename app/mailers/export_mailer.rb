class ExportMailer < ApplicationMailer
  def send_message(export)
    from = "no-reply@catima.unil.ch"
    @export = export

    mail(
      :subject => t("export_mailer.export.subject"),
      :to => export.user.email,
      :from => from,
      :template_name => "export"
    )
  end
end
