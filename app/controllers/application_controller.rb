class ApplicationController < ActionController::Base
  include Pundit
  include FriendlyForwarding
  include MaintenanceMode

  protect_from_forgery :with => :exception, unless: :json_request?
  protect_from_forgery with: :null_session, if: :json_request?
  skip_before_action :verify_authenticity_token, if: :json_request?
  rescue_from ActionController::InvalidAuthenticityToken,
              with: :invalid_auth_token
  before_action :set_current_user, if: :json_request?

  before_action :set_locale

  after_action :track

  # This is a hook for Devise so that it knows to include the required :locale
  # parameter in generated login page URLs.
  def self.default_url_options
    {:locale => I18n.locale}
  end

  protected

  # Track action for the Ahoy analytics. The main one is empty
  # because we don't want to track everything, but subclasses may override and
  # add a specific scope tag & name.
  def track
  end

  def track_event(scope, name = catalog.slug)
    ahoy.track name, request.path_parameters.merge(:scope => scope)
  end

  private

  def json_request?
    request.format.json?
  end

  # Use api_v3_user Devise scope for JSON access
  def authenticate_user!(*args)
    super and return unless args.blank?
    json_request? ? authenticate_api_v3_user! : super
  end

  def invalid_auth_token
    respond_to do |format|
      format.html { redirect_to sign_in_path,
                                error: 'Login invalid or expired' }
      format.json { head 401 }
    end
  end

  # So we can use Pundit policies for api_users
  def set_current_user
    @current_user ||= warden.authenticate(scope: :api_v3_user)
  end

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
