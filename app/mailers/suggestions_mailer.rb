class SuggestionsMailer < ApplicationMailer
  helper :fields, :items

  def send_request(receiver, suggestion)
    I18n.locale = suggestion.catalog.primary_language.to_sym
    @suggestion = suggestion
    mail(
      :subject => "[Catima] - #{t('suggestions_mailer.subject')}",
      :to => receiver,
      :from => ENV['MAIL_SENDER'],
      :template_name => "suggestion"
    )
  ensure
    I18n.locale = I18n.default_locale
  end
end
