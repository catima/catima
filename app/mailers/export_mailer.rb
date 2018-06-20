class ExportMailer < ApplicationMailer
  def send_message(export, user, catalog)
    from = "no-reply@catima.unil.ch"
    subject = "Catima - requested export is ready"

    @catalog = catalog
    @user = user
    @export = export

    mail(
      :subject => subject,
      :to => @user.email,
      :from => from,
      :template_name => "export"
    )
  end
end
