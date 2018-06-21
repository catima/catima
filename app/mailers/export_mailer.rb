class ExportMailer < ApplicationMailer
  def send_message(export)
    # TODO: add traductions
    from = "no-reply@catima.unil.ch"
    subject = "Catima - requested export is ready"

    @export = export

    mail(
      :subject => subject,
      :to => export.user.email,
      :from => from,
      :template_name => "export"
    )
  end
end
