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

  def user(invited_user, catalog, token)
    @token = token
    @user = invited_user
    @invited_by = invited_user.invited_by
    @catalog = catalog
    @role = invited_user.catalog_role(catalog)
    subject = t(
      "invitations_mailer.user.subject",
      :host => app_host,
      :catalog => @catalog.name)

    mail(
      :subject => subject,
      :to => @user.email,
      :reply_to => @invited_by.email
    )
  end
end
