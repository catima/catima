class InvitationsMailer < ApplicationMailer
  def admin(invited_user, token)
    I18n.locale = invited_user.primary_language.to_sym
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
  ensure
    I18n.locale = I18n.default_locale
  end

  def user(invited_user, catalog, token)
    I18n.locale = invited_user.primary_language.to_sym
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
  ensure
    I18n.locale = I18n.default_locale
  end

  def group(invited_user, group, token)
    I18n.locale = invited_user.primary_language.to_sym
    @token = token
    @user = invited_user
    @invited_by = invited_user.invited_by
    @group = group
    subject = t(
      "invitations_mailer.group.subject",
      group: @group.name)

    mail(
      subject: subject,
      to: @user.email,
      reply_to: @invited_by.email
    )
  ensure
    I18n.locale = I18n.default_locale
  end

  def membership(invited_by, membership)
    I18n.locale = membership.user.primary_language.to_sym
    @invited_by = invited_by
    @group = membership.group
    @user = membership.user
    subject = t(
      'invitations_mailer.membership.subject',
      group: @group.name
    )
    mail(
      subject: subject,
      to: @user.email,
      reply_to: @invited_by.email
    )
  ensure
    I18n.locale = I18n.default_locale
  end
end
