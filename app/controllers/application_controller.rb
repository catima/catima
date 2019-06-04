class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery :with => :exception

  before_action :set_locale

  after_action :track_action

  # This is a hook for Devise so that it knows to include the required :locale
  # parameter in generated login page URLs.
  def self.default_url_options
    { :locale => I18n.locale }
  end

  protected

  def track_action
  end

  private

  # Overridden in other controllers to indicate whether the controller is
  # scoped to a specific catalog.
  def catalog_scoped?
    false
  end
  helper_method :catalog_scoped?

  def user_scoped?
    false
  end
  helper_method :user_scoped?

  def favorites_scoped?
    false
  end
  helper_method :favorites_scoped?

  def searches_scoped?
    false
  end
  helper_method :searches_scoped?

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

  # If we've store an explicit redirect path, use it. This allows us to
  # maintain the current page when logging in/out.
  def after_devise_action_for(resource)
    stored_location_for(resource) || root_url
  end
  alias_method :after_sign_in_path_for, :after_devise_action_for
  alias_method :after_sign_out_path_for, :after_devise_action_for
  alias_method :after_sign_up_path_for, :after_devise_action_for
end
