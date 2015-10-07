class InvitationsMailer < ApplicationMailer
  def admin(invited_user, token)
    type = invited_user.system_admin? ? "system_admin" : "catalog_admin"

    @token = token
    @user = invited_user
    @invited_by = invited_user.invited_by
    @catalogs = invited_user.admin_catalogs
    subject = t(
      "invitations_mailer.#{type}.subject",
      :host => app_host,
      :catalog => @catalogs.first.try(:name))

    mail(
      :subject => subject,
      :to => @user.email,
      :reply_to => @invited_by.email,
      :template_name => type
    )
  end
end
