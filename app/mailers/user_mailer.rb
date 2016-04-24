class UserMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  default :template_path => "devise/mailer"

  # Override the devise action to set the appropriate locale
  def reset_password_instructions(user, token, opts={})
    I18n.locale = user.primary_language
    super
  ensure
    I18n.locale = I18n.default_locale
  end
end
