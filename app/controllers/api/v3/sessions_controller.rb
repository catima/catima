class API::V3::SessionsController < Devise::SessionsController
  respond_to :json

  skip_before_action :verify_signed_out_user

  def create
    unless request.format == :json
      sign_out
      render status: :not_acceptable,
             json: { message: "JSON requests only", code: "json_only" } and return
    end
    # auth_options should have `scope: :api_v3_user`
    resource = warden.authenticate!(auth_options)
    if resource.blank?
      render status: :unauthorized,
             json: { message: "Authentication error", code: "authentication_error" } and return
    end

    sign_in(resource_name, resource)
    log_request(resource)
    respond_with resource, location:
      after_sign_in_path_for(resource) do |format|
      format.json do
        render json:
                 {
                   token: current_token,
                   valid_until: Time.current + 23.hours,
                   message: "Authentication successful",
                   code: "authentication_success"
                 }
      end
    end
  end

  def log_request(resource)
    APILog.create(
      user: resource,
      endpoint: request.fullpath,
      remote_ip: request.remote_ip
    )
  end

  private

  def current_token
    request.env['warden-jwt_auth.token']
  end

  def respond_to_on_destroy
    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.json { head :ok }
    end
  end
end
