class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery :with => :exception
  ensure_security_headers

  before_action :set_locale

  # This is a hook for Devise so that it knows to include the required :locale
  # parameter in generated login page URLs.
  def self.default_url_options
    { :locale => I18n.locale }
  end

  private

  def set_locale
    if I18n.locale_available?(params[:locale])
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end

  def current_user
    @current_user ||= (super || Guest.new)
  end
end
