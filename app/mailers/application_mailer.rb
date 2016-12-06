class ApplicationMailer < ActionMailer::Base
  default :from => ENV.fetch("MAIL_SENDER")
  layout "mailer"

  private

  helper_method\
  def app_host
    URI(root_url).host
  end
end
