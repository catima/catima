class ApplicationMailer < ActionMailer::Base
  default :from => "catima@unil.ch"
  layout "mailer"

  private

  helper_method\
  def app_host
    URI(root_url).host
  end
end
