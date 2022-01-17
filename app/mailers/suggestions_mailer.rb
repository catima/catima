class SuggestionsMailer < ApplicationMailer
  helper :fields
  
  def send_request(receiver, suggestion)
    @suggestion = suggestion
    mail(
      :subject => "[Catima] - #{t('suggestions_mailer.subject')}",
      :to => receiver,
      :from => ENV['MAIL_SENDER'],
      :template_name => "suggestion"
    )
  end
end
