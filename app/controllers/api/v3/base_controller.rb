class API::V3::BaseController < ActionController::Base
  include Pundit

  respond_to :json

  DEFAULT_PAGE_SIZE = 1

  before_action :authenticate_user!

  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token
  rescue_from ActionController::InvalidAuthenticityToken,
              with: :invalid_auth_token
  before_action :set_current_user

  rescue_from ActionController::InvalidAuthenticityToken, with: :invalid_auth_token
  rescue_from ActiveRecord::RecordNotFound do
    render_not_found("not_found")
  end
  rescue_from Pundit::NotAuthorizedError do
    render_forbidden("not_allowed")
  end

  before_action :set_locale

  def set_locale
    I18n.locale = if I18n.locale_available?(params[:locale])
                    params[:locale]
                  else
                    I18n.default_locale
                  end
  end

  def routing_error
    render_not_found("not_found")
  end

  def render_unauthorized(code)
    render_response(code, :unauthorized)
  end

  def render_forbidden(code, options={})
    render_response(code, :forbidden, options: options)
  end

  def render_not_found(code, options={})
    render_response(code, :not_found, options: options)
  end

  def render_unprocessable_record(record)
    errors = record.errors.map do |field, message|
      {
        resource: record.class.to_s,
        field: field,
        message: record.errors.full_message(field, message)
      }
    end
    render_unprocessable_entity(errors)
  end

  def render_unprocessable_entity(errors)
    render json: {
      message: t("validation_failed", scope: api_i18n_scope),
      errors: errors
    }, status: :unprocessable_entity
  end

  protected

  # Use api_v3_user Devise scope for JSON access
  def authenticate_user!(*args)
    super and return if args.present?

    authenticate_api_v3_user!
  end

  def invalid_auth_token
    respond_to do |format|
      format.html do
        redirect_to sign_in_path, error: 'Login invalid or expired'
      end
      format.json { head 401 }
    end
  end

  # So we can use Pundit policies for api_users
  # rubocop:disable Naming/MemoizedInstanceVariableName
  def set_current_user
    @current_user ||= warden.authenticate(scope: :api_v3_user)
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def api_i18n_scope
    "api-v3.responses"
  end

  def render_response(code, status, options: {})
    message = t(code, options.merge({ scope: api_i18n_scope }))
    render json: { message: message, code: code }, status: status
  end

  # rubocop:disable Metrics/PerceivedComplexity
  def set_pagination_header(name, _options={})
    scope = instance_variable_get("@#{name}")
    request_params = request.query_parameters
    url_without_params = request.original_url.slice(0..(request.original_url.index("?") - 1)) unless request_params.empty?
    url_without_params ||= request.original_url

    page = {}
    page[:first] = 1 if scope.total_pages > 1 && !scope.first_page?
    page[:last] = scope.total_pages if scope.total_pages > 1 && !scope.last_page?
    page[:next] = scope.current_page + 1 unless scope.last_page?
    page[:prev] = scope.current_page - 1 unless scope.first_page?

    pagination_links = []
    page.each do |k, v|
      new_request_hash = request_params.merge({ :page => v })
      pagination_links << "<#{url_without_params}?#{new_request_hash.to_param}>; rel=\"#{k}\""
    end
    headers["Link"] = pagination_links.join(", ")
    headers["Total"] = scope.total_count
  end
  # rubocop:enable Metrics/PerceivedComplexity
end
