class InvitationsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.invitations_mailer.admin.subject
  #
  def admin
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
